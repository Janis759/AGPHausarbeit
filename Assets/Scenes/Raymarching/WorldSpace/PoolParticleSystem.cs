using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PoolParticleSystem : MonoBehaviour
{
    public GameObject poolPrefab;
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
        Vector3 forceToAdd = new Vector3(-Random.Range(1, 5), Random.Range(1, 5), -Random.Range(15, 30));

        if(nextTime <= Time.time)
        {
            pool.ReuseObject(transform.position, forceToAdd);
            nextTime += Random.Range(.1f, .3f);
        }

    }

    public Vector4[] GetArray()
    {
        Vector4[] output = new Vector4[poolSize];

        int i = 0;
        foreach (var item in pool.pool)
        {
            output[i] = new Vector4(-item.transform.position.x, -item.transform.position.y, -item.transform.position.z, item.activeSelf ? 1 : 0);
            i++;
        }

        return output;
    }
}
