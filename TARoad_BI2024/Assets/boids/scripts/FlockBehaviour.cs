using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FlockBehaviour : MonoBehaviour
{
    
    private Vector3 velocity;
    private Vector3 newVelocity;
    private Vector3 acceleration;


    public float minSpeed = 1, maxSpped = 5;

    // Start is called before the first frame update
    void Start()
    {
        acceleration = new Vector3(0,0,0);
        velocity = Random.insideUnitSphere;
        velocity.Normalize();
        float velocityMag = Random.Range(minSpeed, maxSpped);
        velocity *= velocityMag;


    }

    // Update is called once per frame
    void Update()
    {

        Vector3 tarPos = transform.position;
        tarPos += velocity * Time.deltaTime;
        transform.position = tarPos;

        newVelocity =  velocity + acceleration * Time.deltaTime;
        newVelocity = Vector3.Normalize(newVelocity) * velocity.magnitude;

        if (newVelocity.sqrMagnitude > maxSpped * maxSpped)
        {
            newVelocity = Vector3.Normalize(newVelocity) * maxSpped;
        }

    }
    private void LateUpdate()
    {
        velocity = newVelocity;
    }

    public void setVelocity(Vector3 vel)
    {
        velocity = vel;
    }

    public Vector3 getVelocity()
    {
        return velocity;
    }

    public void setAcceleration(Vector3 accel)
    {
        acceleration = accel;
    }

    public Vector3 getAcceleration()
    {
        return acceleration;
    }

}
