using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FlockControl : MonoBehaviour
{
    public GameObject flockEntity;
    public int flockAmount = 1;
    public float AlPerception = 10;
    public float CoPerception = 15;
    public float SepPerception = 5;

    public float CohesionCoeff = 5;
    public float SeparationCoeff = 3;

    public float maxAccelerationMag = 2f;


    private FlockBehaviour[] flock;
    private Vector3[] accelArray;

    // Start is called before the first frame update
    void Start()
    {
        accelArray = new Vector3[flockAmount];
        flock = new FlockBehaviour[flockAmount];
        for(int i = 0; i < flockAmount; i++)
        {
            Vector3 pos = new Vector3(Random.Range(-5, 5), Random.Range(0, 6), Random.Range(-3, 3));
            GameObject newGameObject = Instantiate(flockEntity, pos, Quaternion.identity);

            FlockBehaviour fb = newGameObject.GetComponent<FlockBehaviour>();
            if (fb != null)
                flock[i] = fb;

        }
    }

    // Update is called once per frame
    void Update()
    {
        for (int i = 0; i < flockAmount; i++)
        {
            accelArray[i] = new Vector3(0, 0, 0);
        }

        for (int i = 0; i < flockAmount; i++)
        {
            accelArray[i] += Alignment(flock[i]);
            accelArray[i] += Cohesion(flock[i]);
            accelArray[i] += Separation(flock[i]);

            if (accelArray[i].sqrMagnitude > maxAccelerationMag * maxAccelerationMag)
            {
                accelArray[i] = Vector3.Normalize(accelArray[i]) * maxAccelerationMag;
            }
        }

    }

    private void LateUpdate()
    {
        for (int i = 0; i < flockAmount; i++)
        {
            flock[i].setAcceleration(accelArray[i]);
        }
    }

    Vector3 Alignment(FlockBehaviour fb)
    {
        Vector3 averageVel = new Vector3(0, 0, 0);
        int otherCount = 0;
        foreach (FlockBehaviour other in flock)
        {
            if(other != fb)
            {
                float dis = Vector3.Distance(fb.transform.position, other.transform.position);
                
                
                if(dis < AlPerception)
                {
                    averageVel += other.getVelocity();
                    otherCount++;
                }

            }
        }
        if (otherCount > 0)
        {
            averageVel /= otherCount;
            //未乘系数
            Vector3 accel = (averageVel - fb.getVelocity());
            //最大加速度限制累加后再做
            //if (accel.sqrMagnitude > Mathf.Pow(maxAccelerationMag, 2f))
            //{
            //    accel = Vector3.Normalize(accel) * maxAccelerationMag;

            //}
            //fb.setAcceleration(accel);
            return accel;
        }
        else
        {
            return new Vector3(0, 0, 0);
        }
    }

    Vector3 Cohesion(FlockBehaviour fb)
    {
        Vector3 averagePos = fb.transform.position;
        int otherCount = 1;
        foreach (FlockBehaviour other in flock)
        {

            if (other != fb)
            {
                float dis = Vector3.Distance(fb.transform.position, other.transform.position);


                if (dis < CoPerception)
                {
                    averagePos += other.transform.position;
                    otherCount++;
                }

            }
        }
        if (otherCount > 0)
        {
            averagePos /= otherCount;
            Vector3 offsetDis = averagePos - fb.transform.position;

            //加速度的平方与距离成正比,未乘系数
            float n = Mathf.Sqrt(offsetDis.magnitude);

            Vector3 accel = CohesionCoeff *  Vector3.Normalize(offsetDis) * n;

            return accel;
        }
        else
        {
            return new Vector3(0, 0, 0);
        }
    }

    Vector3 Separation(FlockBehaviour fb)
    {
        Vector3 distanceSum = new Vector3(0, 0, 0);
        foreach (FlockBehaviour other in flock)
        {

            if (other != fb)
            {
                float dis = Vector3.Distance(fb.transform.position, other.transform.position);


                if (dis < SepPerception && dis > 0.0000001f)
                {
                    Vector3 dir = fb.transform.position - other.transform.position;
                    distanceSum += dir.normalized * (1 / dis);
                }

            }
        }

        Vector3 accel = distanceSum.normalized * SeparationCoeff;

        return accel;
    }

}
