using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FlockControl : MonoBehaviour
{
    public GameObject flockEntity;
    public int flockAmount = 20;
    public float spawnRadius = 10f;
    [Range(1f, 20f)]
    public float velocity = 10f;
    [Range(0.0f, 0.9f)]
    public float velocityVarration = 0.2f;
    [Range(0.1f, 20.0f)]
    public float RotationCoeff = 2f;
    [Range(0.1f, 10.0f)]
    public float NeighbourDist = 2f;

    public LayerMask searchLayer;


    void Start()
    {
        for(int i = 0; i< flockAmount; i++)
        {
            Vector3 pos = transform.position + Random.insideUnitSphere * spawnRadius;
            Quaternion rota = Quaternion.Slerp(transform.rotation, Random.rotation, 0.5f);

            GameObject boid =  Instantiate(flockEntity, pos, rota);
            if(boid.GetComponent<FlockBehaviour>() != null)
            {
                boid.GetComponent<FlockBehaviour>().controller = this;
            }
        }
    }



}
