using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ObraDinnPE : MonoBehaviour
{
    public Material diterMat;
    public Camera mainCam;

    // Start is called before the first frame update
    void Start()
    {
        mainCam = GetComponent<Camera>();
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dst)
    {

        RenderTexture main = RenderTexture.GetTemporary(820, 470, 0, RenderTextureFormat.ARGB32);
        main.filterMode = FilterMode.Bilinear;

        Graphics.Blit(src, main, diterMat);

        Graphics.Blit(main, dst);


        RenderTexture.ReleaseTemporary(main);

    }

}
