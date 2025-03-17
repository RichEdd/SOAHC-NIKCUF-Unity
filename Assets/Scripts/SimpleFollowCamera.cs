using UnityEngine;

public class SimpleFollowCamera : MonoBehaviour
{
    public Transform target;
    public float smoothSpeed = 0.125f;
    public Vector3 offset = new Vector3(0, 1, -10);

    // Update is called once per frame
    void Update()
    {
        if (target == null)
            return;

        // Calculate the desired position
        Vector3 desiredPosition = target.position + offset;

        // Smoothly move the camera
        transform.position = Vector3.Lerp(transform.position, desiredPosition, smoothSpeed * Time.deltaTime);
    }
}