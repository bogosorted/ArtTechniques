using UnityEngine;

[RequireComponent(typeof(MeshFilter))]
[RequireComponent(typeof(MeshRenderer))]

public class ProceduralMesh : MonoBehaviour
{   

    [HideInInspector]
    public Mesh mesh;

    Vector3[] vertices;
    Vector2[] uvs;
    int[] triangles;

    public int quadCountX = 2;
    public int quadCountY = 4;

    void Start()
    {
        mesh = new Mesh();
        CreateDynamicMesh();
        UpdateMesh();
        GetComponent<MeshFilter>().mesh = mesh;
        mesh.MarkDynamic();

    }
    void Update(){
          mesh.RecalculateNormals();
          mesh.MarkModified();
    }

    void CreateDynamicMesh()
    {
        int verticesCount =  (quadCountX + 1) * (quadCountY + 1);
        int trianglesPointsCount = quadCountX * quadCountY * 6;

        vertices = new Vector3[verticesCount];
        triangles = new int[trianglesPointsCount];

        float scaleX = 1f / quadCountX; 
        float scaleY = 1f / quadCountY; 

        // set vertices
        for(int x = 0, i = 0; x <= quadCountX; x++)
            for(int y = 0; y <= quadCountY; y++, i++)
                vertices[i] = new Vector3(x * scaleX,y * scaleY,0);

        // set triangles
        for(int y = 0, x = 0, i = 0; x <= quadCountX - 1 ; x++)
        {
            //draw quad
            for(int j = 0; j <= quadCountY - 1; y += 6, j++)
            {
                // first triangle
                triangles[y] = i;
                triangles[y + 1] = i + 1;
                triangles[y + 2] = i + 1 + quadCountY;
                // second triangle
                triangles[y + 3] = i + 1 + quadCountY;
                triangles[y + 4] = i + 1;   
                triangles[y + 5] = i + 2 + quadCountY;
                i++;
            }
            i++;
        }
    }

    void UpdateMesh()
    {

        mesh.Clear();

        mesh.vertices = vertices;
        mesh.triangles = triangles;

        mesh.RecalculateNormals();
    }
}