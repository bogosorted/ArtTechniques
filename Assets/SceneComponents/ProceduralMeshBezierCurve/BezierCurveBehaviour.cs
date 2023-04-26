using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BezierCurveBehaviour : MonoBehaviour
{
    [SerializeField] Transform pos;
    [SerializeField] Transform startPosition;
    [SerializeField] Transform finalPosition;
    [SerializeField] Transform p0;
    [SerializeField] Transform p1;

    [SerializeField] Material bezierMaterial;
    [SerializeField] ProceduralMesh pm;

    void Update()
    {   
        Vector3 center = (finalPosition.position + startPosition.position)/2 - pos.position;
        pm.mesh.bounds = new Bounds(center, Vector3.one * Vector3.Distance(finalPosition.position,startPosition.position));
       
        bezierMaterial.SetVector("_StartPos", pos.InverseTransformPoint(startPosition.position));
        bezierMaterial.SetVector("_FinalPos", pos.InverseTransformPoint(finalPosition.position));
        bezierMaterial.SetVector("_P0", pos.InverseTransformPoint(p0.position));
        bezierMaterial.SetVector("_P1", pos.InverseTransformPoint(p1.position));
    }
}

