using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Test1 : MonoBehaviour
{
    private float radius = 0;
    public float maxRadius = 10;
    public float radiusGrowth = 0.01f;
    public LayerMask mask;
    private LineRenderer lr;
    public Transform rayTip;
    private Transform hitPos;
    private Vector3 lastPoint;
    public Marker markerPrefab;
    private GameObject container;

    // Start is called before the first frame update
    void Start()
    {
        lr = GetComponent<LineRenderer>();
        GameObject go = new GameObject("Hit");
        go.transform.parent = this.transform;
        go.transform.position = new Vector3(-420, -420, -420);
        hitPos = go.GetComponent<Transform>();
        container = new GameObject("Container");
        container.transform.SetParent(transform);
        for (int i = 0; i < 25; i++)
        {
            Instantiate(markerPrefab, container.transform);
        }
    }

    // Update is called once per frame
    void Update()
    {
        SetHitPoint();
        lr.SetPosition(0, transform.position);
        lr.SetPosition(1, hitPos.position);

        GenerateSpheres();
    }

    private Vector3 GetNearestPoint(Vector3 point)
    {
        Collider[] hitColliders = Physics.OverlapSphere(point, radius, mask);
        while (hitColliders.Length == 0 && radius < maxRadius)
        {
            hitColliders = Physics.OverlapSphere(point, radius, mask);
            radius += radiusGrowth;
        }
        if (hitColliders.Length > 0)
            return hitColliders[0].ClosestPoint(point);
        return new Vector3(-420, -420, -420);
    }

    private void GenerateSpheres()
    {
        lastPoint = transform.position;
        Vector3 dir = (rayTip.position - transform.position).normalized;
        Vector3 np = GetNearestPoint(lastPoint);
        float dist = Vector3.Distance(lastPoint, np);
        for (int i = 0; i < 25 ; i++)
        {
            if (Vector3.Distance(transform.position, hitPos.position) < Vector3.Distance(transform.position, lastPoint) || dist > 50 || dist < 0.02)
            {
                
                container.transform.GetChild(i).gameObject.SetActive(false);


            }
            else
            {
                Transform t = container.transform.GetChild(i);
                t.position = lastPoint;
                t.GetComponent<Marker>().scale = dist * 2;
                t.gameObject.SetActive(true);
                lastPoint += dir * dist;
                np = GetNearestPoint(lastPoint);
                dist = Vector3.Distance(lastPoint, np);
                Debug.Log(i);

            }
        }
    }

    private void SetHitPoint()
    {
        Vector3 dir = (rayTip.position - transform.position).normalized;

        RaycastHit hit;
        Physics.Raycast(transform.position, dir, out hit, Vector3.Distance(transform.position, rayTip.position), mask);
        if (hit.point == Vector3.zero)
            hitPos.position = rayTip.position;
        else
            hitPos.position = hit.point;

    }
}
