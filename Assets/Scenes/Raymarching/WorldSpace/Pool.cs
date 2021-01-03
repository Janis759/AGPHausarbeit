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

	public void ReuseObject(Vector3 position)
	{
		if (pool.Count != 0)
		{
			GameObject objectToReuse = pool.Dequeue();
			pool.Enqueue(objectToReuse);

			objectToReuse.SetActive(true);
			objectToReuse.transform.position = position;
			objectToReuse.GetComponent<Rigidbody>().velocity = Vector3.zero;
		}
	}
}
