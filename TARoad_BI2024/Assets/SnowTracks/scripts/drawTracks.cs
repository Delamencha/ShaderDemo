using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class drawTracks : MonoBehaviour
{
    public Camera mainCam;
    public Shader drawShader;
    
    private Material drawMat;
    private Material snowMat;
    private RenderTexture splatMap;
    private RaycastHit hit; 

    void Start()
    {

        drawMat = new Material(drawShader);
        drawMat.SetVector("_DrawColor", Color.red);

        snowMat = GetComponent<MeshRenderer>().material;
        splatMap = new RenderTexture(1024, 1024, 0, RenderTextureFormat.ARGBFloat);
        snowMat.SetTexture("_HeightMap", splatMap);

    }

    
    void Update()
    {
        if (Input.GetKey(KeyCode.Mouse0))
        {
            if(Physics.Raycast(mainCam.ScreenPointToRay(Input.mousePosition), out hit)){

                drawMat.SetVector("_Coordinates", new Vector4(hit.textureCoord.x, hit.textureCoord.y, 0, 0));
                RenderTexture temp = RenderTexture.GetTemporary(splatMap.width, splatMap.height, 0, RenderTextureFormat.ARGBFloat);
                Graphics.Blit(splatMap, temp);
                Graphics.Blit(temp, splatMap, drawMat);
                RenderTexture.ReleaseTemporary(temp);

            }
        }
    }

    private void OnGUI()
    {
        GUI.DrawTexture(new Rect(0, 0, 256, 256), splatMap, ScaleMode.ScaleToFit, false, 1);
    }


}
