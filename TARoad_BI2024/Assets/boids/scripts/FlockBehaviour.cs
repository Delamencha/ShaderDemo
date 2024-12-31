using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FlockBehaviour : MonoBehaviour
{

    public FlockControl controller;

    float noiseOffset;


    // Start is called before the first frame update
    void Start()
    {
        noiseOffset = Random.value * 10.0f;

    }

    Vector3 GetSeparationVec(Transform t)
    {
        Vector3 diff = transform.position - t.transform.position;
        float diffLen = diff.magnitude;

        return (diff / diffLen) * Mathf.Clamp01(1.0f - diffLen / controller.NeighbourDist);
    }

    // Update is called once per frame
    void Update()
    {
        Vector3 currentPos = transform.position;
        Quaternion currentRota = transform.rotation;

        var noise = Mathf.PerlinNoise(Time.time, noiseOffset) * 2.0f - 1.0f;

        float currentVel = controller.velocity * ( 1.0f + noise * controller.velocityVarration);

        Vector3 alignment = controller.transform.forward;
        Vector3 cohesion = controller.transform.position;
        Vector3 separation = Vector3.zero;

        Collider[] neighbour = Physics.OverlapSphere(currentPos, controller.NeighbourDist, controller.searchLayer);

        foreach(Collider co in neighbour)
        {
            if(co.gameObject == gameObject)
            {
                continue;
            }

            Transform t = co.transform;
            alignment += t.forward;
            cohesion += t.position;
            separation += GetSeparationVec(t);

        }

        if(neighbour.Length > 0)
        {
            //Debug.Log(neighbour.Length);
            alignment /= neighbour.Length;
            cohesion /= neighbour.Length;
        }

        cohesion = (cohesion - currentPos).normalized;


        Vector3 direction = alignment + cohesion + separation;

        //是用 Vector3.forward 为基准而非 transform.forward
        Quaternion rotation = Quaternion.FromToRotation(Vector3.forward, direction.normalized);


        if(rotation != currentRota)
        {
            //Time.deltaTime介入， 同时RotationCoeff越大，it越靠近0，角度越靠近rotation
            float it = Mathf.Exp(-controller.RotationCoeff * Time.deltaTime);
            transform.rotation = Quaternion.Lerp(rotation, currentRota, it);
        }


        transform.position = currentPos + transform.forward * currentVel * Time.deltaTime;

        //boundaryMovement();
    }

    void boundaryMovement()
    {
        if (transform.position.x > 6)
        {
            transform.position = new Vector3(-6, transform.position.y, transform.position.z);
        }
        if (transform.position.x < -6)
        {
            transform.position = new Vector3(6, transform.position.y, transform.position.z);
        }
        if (transform.position.y > 10)
        {
            transform.position = new Vector3(transform.position.x, 0, transform.position.z);
        }
        if (transform.position.y < 0)
        {
            transform.position = new Vector3(transform.position.x, 10, transform.position.z);
        }
        if (transform.position.z > 5)
        {
            transform.position = new Vector3(transform.position.x, transform.position.y, -5);
        }
        if (transform.position.z < -5)
        {
            transform.position = new Vector3(transform.position.x, transform.position.y, 5);
        }
    }


}
