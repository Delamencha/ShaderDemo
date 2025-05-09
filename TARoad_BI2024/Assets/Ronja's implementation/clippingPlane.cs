using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteAlways]
public class clippingPlane : MonoBehaviour
{

    public Material mat;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {

        Plane plane = new Plane(transform.up, transform.position);

        Vector4 planeRepresentation = new Vector4(plane.normal.x, plane.normal.y, plane.normal.z, plane.distance);

        mat.SetVector("_Plane", planeRepresentation);

    }
}
