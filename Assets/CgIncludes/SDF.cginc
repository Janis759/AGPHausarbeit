#ifndef SDF_INCLUDED
#define SDF_INCLUDED

float GetDistanceSphere(float3 p, float3 center, float radius)
{
    float d = length(p + center) - radius;

    return d;
}

float sdBox(float3 p, float3 center, float3 b)
{
    float3 q = abs(p - center) - b;
    return length(max(q, 0)) + min(max(q.x, max(q.y, q.z)), 0);
}

float CombinedSmoothDistance(float k, float d1, float d2)
{
    float h = clamp(0.5 + 0.5 * (d1 - d2) / k, 0.0, 1.0);
    return lerp(d1, d2, h) - k * h * (1.0 - h);
}

float CombinedDistance(float d1, float d2)
{
    float d = min(d1, d2);
    return d;
}

#endif // SDF_INCLUDED