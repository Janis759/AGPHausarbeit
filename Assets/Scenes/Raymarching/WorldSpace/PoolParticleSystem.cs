using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PoolParticleSystem : MonoBehaviour
{
    public GameObject poolPrefab;
    public Transform directionHelper;
    public float launchForce;
    public float marginPercentage;
    [Range(0.1f, 0.5f)]
    public float spawnRateMin, spawnRateMax;

    public int poolSize = 20;

    private Pool pool;
    private float nextTime;


    private void Start()
    {
        pool = gameObject.AddComponent<Pool>();
        pool.CreatePool(poolPrefab, poolSize);

    }

    void Update()
    {

        Vector3 forceToAdd = directionHelper.position - transform.position;
        forceToAdd = forceToAdd.normalized * launchForce;
        Vector3 marginBase = forceToAdd * marginPercentage / 100;
        Vector3 margin = new Vector3(Random.Range(-marginBase.x, marginBase.x), Random.Range(-marginBase.y, marginBase.y), Random.Range(-marginBase.z, marginBase.z));
        Debug.Log(margin);

        if(nextTime <= Time.time)
        {
            pool.ReuseObject(transform.position, forceToAdd + margin);
            nextTime += Random.Range(spawnRateMin, spawnRateMin);
        }

    }

    public Vector4[] GetArray()
    { 
        Vector4[] output = new Vector4[poolSize];
        if (pool != null)
        {
            int i = 0;
            foreach (var item in pool.pool)
            {
                output[i] = new Vector4(-item.transform.position.x, -item.transform.position.y, -item.transform.position.z, item.activeSelf ? 1 : 0);
                i++;
            }
        }
        return output;
    }

    private void OnDrawGizmos()
    {
        Gizmos.color = Color.green;
        Gizmos.DrawSphere(transform.position, 0.3f);
        Gizmos.DrawLine(transform.position, directionHelper.position);
    }
}
