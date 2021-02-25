using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Pool : MonoBehaviour
{
	public Queue<GameObject> pool = new Queue<GameObject>();
	
	public void CreatePool(GameObject prefab, int poolSize)
	{
		if (pool.Count == 0)
		{
			Transform poolHolder = new GameObject("Pool").transform;
			poolHolder.parent = transform;

			for (int i = 0; i < poolSize; i++)
			{
				GameObject newObject = Instantiate(prefab);
				newObject.SetActive(false);
				pool.Enqueue(newObject);
				newObject.transform.SetParent(poolHolder);
			}
		}
	}

	public void ReuseObject(Vector3 position, Vector3 forceToAdd)
	{
		if (pool.Count != 0)
		{
			GameObject objectToReuse = pool.Dequeue();
			pool.Enqueue(objectToReuse);

			objectToReuse.SetActive(true);
			objectToReuse.transform.position = position;
			Rigidbody rb = objectToReuse.GetComponent<Rigidbody>();
			rb.velocity = Vector3.zero;
			rb.AddForce(forceToAdd);
		}
	}
}
