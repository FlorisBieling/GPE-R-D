using UnityEngine;

public class TopDownCameraMovement : MonoBehaviour
{
    public float moveSpeed = 10f;
    public float sprintMultiplier = 4f;

    void Update()
    {
        float horizontal = Input.GetAxis("Horizontal");
        float vertical = Input.GetAxis("Vertical");

        float currentSpeed = moveSpeed;

        if (Input.GetKey(KeyCode.LeftShift))
        {
            currentSpeed *= sprintMultiplier;
        }

        Vector3 move = transform.forward * vertical + transform.right * horizontal;
        move.y = 0f;

        transform.position += move * currentSpeed * Time.deltaTime;
    }
}