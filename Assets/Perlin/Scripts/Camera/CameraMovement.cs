using UnityEngine;

public class CameraHeightControl : MonoBehaviour
{
    public float heightSpeed = 10f;
    public float minHeight = 5f;
    public float maxHeight = 800f;

    void Update()
    {
        float yMove = 0f;

        if (Input.GetKey(KeyCode.M)) yMove = 1f;
        if (Input.GetKey(KeyCode.N)) yMove = -1f;

        Vector3 newPos = transform.position + new Vector3(0f, yMove, 0f) * heightSpeed * Time.deltaTime;
        newPos.y = Mathf.Clamp(newPos.y, minHeight, maxHeight);

        transform.position = newPos;
    }
}