using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public struct boid_ComputeData {
    public Vector3 position;
    public Vector3 direction;
    public float noise_offset;
}

public class GPU_Flock : MonoBehaviour
{
    public int boidAmount = 100;
    public ComputeShader boid_compute;

    public GameObject boidPrefab;
    public float spawnRadius;
    [Range(0.1f, 20.0f)]
    public float rotationCoeff;
    [Range(0.1f, 10.0f)]
    public float neighbourDist;

    private ComputeBuffer boidBuffer;
    private boid_ComputeData[] boidData;
    int kernel;
    uint threadGroupSize;

    private GameObject[] boidsTransform;

    void Start()
    {
        
        kernel = boid_compute.FindKernel("simpleBoids"); 
        boid_compute.GetKernelThreadGroupSizes(kernel, out threadGroupSize, out _, out _);
        boidBuffer = new ComputeBuffer(boidAmount, sizeof(float) * 7);
        boidsTransform = new GameObject[boidAmount];
        boidData = new boid_ComputeData[boidAmount];

        for(int i = 0; i < boidAmount; i++)
        {
            Vector3 pos = transform.position + Random.insideUnitSphere * spawnRadius;
            Quaternion rota = Quaternion.Slerp(transform.rotation, Random.rotation, 0.5f);

            GameObject boid = Instantiate(boidPrefab, pos, rota);
            boidsTransform[i] = boid;
        }


    }

    // Update is called once per frame
    void Update()
    {
        boid_compute.SetBuffer(kernel, "boidBuffer", boidBuffer);
        int threadGroupCount = (int)((boidAmount + threadGroupSize - 1) / threadGroupSize);
        boid_compute.Dispatch(kernel, threadGroupCount, 1, 1);
        boidBuffer.GetData(boidData);

        for (int i = 0; i < boidData.Length; i++)
        {
            boidsTransform[i].transform.position = boidData[i].position;
            Vector3 direciton = boidData[i].direction;
            Quaternion currentRotation = boidsTransform[i].transform.rotation;
            Quaternion rotation = Quaternion.FromToRotation(Vector3.forward, direciton);
            float it = Mathf.Exp(-rotationCoeff * Time.deltaTime);
            boidsTransform[i].transform.rotation = Quaternion.Lerp(rotation, currentRotation, it);

        }

    }

    private void OnDestroy()
    {
        boidBuffer.Dispose();
    }
}
