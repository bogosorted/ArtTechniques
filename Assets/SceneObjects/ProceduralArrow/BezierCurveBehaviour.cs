using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BezierCurveBehaviour : MonoBehaviour
{
    public Transform pos, startPosition, finalPosition, p0, p1;

    [SerializeField] Material bezierMaterial;
    [SerializeField] ProceduralMesh pm;

    Coroutine fadeCoroutine;
    public float speed;

    public bool active;

     void Awake()
    {
          SetRendering(true,false);  
    }
    public void SetRendering(bool active, bool fade = true)
    {
        this.active = active;

        if (fadeCoroutine != null) {StopCoroutine(fadeCoroutine);}
        if(!fade) return;
        fadeCoroutine = StartCoroutine(Fade(active));
       

    }
    
    public IEnumerator Fade(bool inOut)
    {
        float x, y;
        x = inOut ? 0 : 1;
        GetComponent<Renderer>().enabled = true;

        while (inOut? x < 1 : x > 0)
        {
            x += (inOut ? 1 : -1) * (speed * Time.deltaTime * 2.8f);
            y = (-x * x + 2 * x);
            GetComponent<Renderer>().material.SetFloat("_Fade",y);
            yield return null;
        }
        GetComponent<Renderer>().enabled = inOut;

    }

    void Update()
    {   

        if(!active){ return;} 
        
        Vector3 center = (finalPosition.position + startPosition.position)/2 - pos.position;
        pm.mesh.bounds = new Bounds(center, Vector3.one * Vector3.Distance(finalPosition.position,startPosition.position));

        bezierMaterial.SetVector("_StartPos", pos.InverseTransformPoint(startPosition.position));
        bezierMaterial.SetVector("_FinalPos", pos.InverseTransformPoint(finalPosition.position));
        bezierMaterial.SetVector("_P0", pos.InverseTransformPoint(p0.position));
        bezierMaterial.SetVector("_P1", pos.InverseTransformPoint(p1.position));
    }
 
}

