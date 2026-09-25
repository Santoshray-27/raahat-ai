import time
from fastapi import APIRouter, Query, HTTPException
from app.core.response import success_response
from app.providers.manager import provider_manager
from app.schemas.routes import RoutePlanRequest
from app.schemas.enums import ServiceType
import asyncio
from app.schemas.common import GeoPoint
from app.core.logging import logger

router = APIRouter()

_GEOCODE_CACHE = {}

@router.post("/routes/plan")
async def plan_route(req: RoutePlanRequest):
    t_start = time.time()
    
    t0 = time.time()
    route_data = await provider_manager.plan_route(
        origin=req.origin,
        destination=req.destination,
        avoid_highways=req.avoid_highways,
        avoid_tolls=req.avoid_tolls
    )
    t_route = (time.time() - t0) * 1000
    logger.info(f"ROUTE_CALCULATION: {t_route:.2f} ms")
    
    # Calculate route midpoint for better coverage
    midpoint = GeoPoint(
        latitude=(req.origin.latitude + req.destination.latitude) / 2.0,
        longitude=(req.origin.longitude + req.destination.longitude) / 2.0
    )
    
    sample_points = [req.origin, midpoint, req.destination]
    
    target_categories = [
        ServiceType.HOSPITAL,
        ServiceType.AMBULANCE,
        ServiceType.POLICE,
        ServiceType.FIRE_BRIGADE,
        ServiceType.MECHANIC,
        ServiceType.PUNCTURE_REPAIR,
        ServiceType.TOWING,
        ServiceType.FUEL_DELIVERY
    ]

    all_services = []
    seen_coords = set()

    # Semaphore to prevent rate-limiting the provider APIs
    sem = asyncio.Semaphore(12)

    async def fetch_category(pt, category):
        async def _do_fetch():
            async with sem:
                svcs, _ = await provider_manager.get_nearby_services(
                    location=pt,
                    service_types=[category],
                    radius_km=15.0,
                    limit=3,
                    fast_only=True
                )
                return svcs
                
        try:
            # Very strict absolute timeout for route planning (4.0 seconds max per category including queue time)
            return await asyncio.wait_for(_do_fetch(), timeout=4.0)
        except asyncio.TimeoutError:
            logger.warning(f"Service discovery absolute timeout for {category.value} at {pt.latitude},{pt.longitude}")
            return []
        except Exception as e:
            logger.error(f"Service discovery error for {category.value}: {e}")
            return []

    t1 = time.time()
    tasks = []
    for pt in sample_points:
        for cat in target_categories:
            tasks.append(fetch_category(pt, cat))
            
    results = await asyncio.gather(*tasks, return_exceptions=True)
    
    for res in results:
        if isinstance(res, list):
            for svc in res:
                # Deduplicate by coordinates
                coord = (svc.location.latitude, svc.location.longitude)
                if coord not in seen_coords:
                    seen_coords.add(coord)
                    all_services.append(svc)
                    
    t_service = (time.time() - t1) * 1000
    logger.info(f"SERVICE_DISCOVERY: {t_service:.2f} ms")
    
    route_data.nearby_emergency_services = all_services
    
    t_total = (time.time() - t_start) * 1000
    logger.info(f"TOTAL_ROUTE_REQUEST: {t_total:.2f} ms")
    
    return success_response(data=route_data.model_dump())

@router.get("/routes/geocode")
async def geocode_location(q: str = Query(..., description="Location text to geocode")):
    q_lower = q.lower().strip()
    if q_lower in _GEOCODE_CACHE:
        return success_response(data=_GEOCODE_CACHE[q_lower])

    t0 = time.time()
    result = await provider_manager.geocode(q)
    t_geo = (time.time() - t0) * 1000
    logger.info(f"GEOCODE ({q}): {t_geo:.2f} ms")
    
    if not result:
        raise HTTPException(status_code=404, detail="Could not geocode location")
    
    lat, lon, display = result
    data = {
        "latitude": lat,
        "longitude": lon,
        "display_name": display
    }
    _GEOCODE_CACHE[q_lower] = data
    return success_response(data=data)
