using UnityEngine;
using UnityEngine.InputSystem;

public class PlayerController : MonoBehaviour
{
    [Header("Movement Settings")]
    public float moveSpeed = 5f;
    public float jumpForce = 10f;
    public float dashForce = 15f;
    public float dashCooldown = 0.5f;
    
    [Header("Double Jump Settings")]
    public bool canDoubleJump = true;
    public float doubleJumpForce = 8f;
    
    [Header("Wall Jump Settings")]
    public bool canWallJump = true;
    public float wallSlideSpeed = 1f;
    public float wallJumpForce = 12f;
    public Vector2 wallJumpDirection = new Vector2(1, 2);
    public float wallCheckDistance = 0.5f;
    
    [Header("Controller Settings")]
    public float controllerDeadzone = 0.1f;
    
    // Private variables
    private Rigidbody2D rb;
    private bool isGrounded;
    private bool isWallSliding;
    private bool hasDoubleJumped;
    private bool canDash = true;
    private bool isDashing;
    private float dashCooldownTimer;
    private float moveInput;
    private int facingDirection = 1; // 1 for right, -1 for left
    
    // Input variables
    private bool jumpPressed;
    private bool dashPressed;
    
    // References
    private SpriteRenderer spriteRenderer;
    private PlayerInput playerInput;
    private InputAction moveAction;
    private InputAction jumpAction;
    private InputAction dashAction;
    
    void Awake()
    {
        // Set up Input System
        playerInput = GetComponent<PlayerInput>();
        if (playerInput == null)
        {
            // Add PlayerInput component if it doesn't exist
            playerInput = gameObject.AddComponent<PlayerInput>();
            playerInput.defaultActionMap = "Player";
        }
        
        // Get references to actions
        moveAction = playerInput.actions.FindAction("Move");
        jumpAction = playerInput.actions.FindAction("Jump");
        dashAction = playerInput.actions.FindAction("Dash");
        
        // Set up callbacks
        if (jumpAction != null)
            jumpAction.performed += ctx => OnJumpInput(true);
        if (jumpAction != null)
            jumpAction.canceled += ctx => OnJumpInput(false);
        if (dashAction != null)
            dashAction.performed += ctx => OnDashInput(true);
        if (dashAction != null)
            dashAction.canceled += ctx => OnDashInput(false);
    }
    
    void Start()
    {
        rb = GetComponent<Rigidbody2D>();
        spriteRenderer = GetComponent<SpriteRenderer>();
        
        // Normalize wall jump direction
        wallJumpDirection.Normalize();
    }

    void Update()
    {
        // Only process input if not dashing
        if (!isDashing)
        {
            // Get movement input (supports both keyboard and controller)
            ProcessMovementInput();
            
            // Update facing direction
            if (moveInput > controllerDeadzone)
            {
                facingDirection = 1;
                spriteRenderer.flipX = false;
            }
            else if (moveInput < -controllerDeadzone)
            {
                facingDirection = -1;
                spriteRenderer.flipX = true;
            }
            
            // Process jump input (for keyboard fallback)
            if (Input.GetKeyDown(KeyCode.Space))
            {
                OnJumpInput(true);
            }
            if (Input.GetKeyUp(KeyCode.Space))
            {
                OnJumpInput(false);
            }
            
            // Process dash input (for keyboard fallback)
            if (Input.GetKeyDown(KeyCode.LeftShift))
            {
                OnDashInput(true);
            }
            if (Input.GetKeyUp(KeyCode.LeftShift))
            {
                OnDashInput(false);
            }
            
            // Check for wall sliding
            CheckWallSlide();
        }
        
        // Dash cooldown timer
        if (!canDash)
        {
            dashCooldownTimer -= Time.deltaTime;
            if (dashCooldownTimer <= 0)
            {
                canDash = true;
            }
        }
    }
    
    void ProcessMovementInput()
    {
        // Try to get input from the Input System first
        if (moveAction != null)
        {
            Vector2 inputVector = moveAction.ReadValue<Vector2>();
            moveInput = inputVector.x;
        }
        // Fallback to legacy input system
        else
        {
            moveInput = Input.GetAxis("Horizontal");
        }
    }
    
    void OnJumpInput(bool pressed)
    {
        jumpPressed = pressed;
        
        if (pressed)
        {
            if (isGrounded)
            {
                Jump();
            }
            else if (canDoubleJump && !hasDoubleJumped && !isWallSliding)
            {
                DoubleJump();
            }
            else if (canWallJump && isWallSliding)
            {
                WallJump();
            }
        }
    }
    
    void OnDashInput(bool pressed)
    {
        dashPressed = pressed;
        
        if (pressed && canDash)
        {
            StartDash();
        }
    }
    
    void FixedUpdate()
    {
        if (isDashing)
        {
            return; // Don't process movement during dash
        }
        
        // Horizontal movement
        if (!isWallSliding)
        {
            rb.linearVelocity = new Vector2(moveInput * moveSpeed, rb.linearVelocity.y);
        }
        else
        {
            // Wall sliding - slow descent
            rb.linearVelocity = new Vector2(0, Mathf.Clamp(rb.linearVelocity.y, -wallSlideSpeed, float.MaxValue));
        }
    }
    
    void Jump()
    {
        rb.linearVelocity = new Vector2(rb.linearVelocity.x, jumpForce);
        isGrounded = false;
        hasDoubleJumped = false;
    }
    
    void DoubleJump()
    {
        rb.linearVelocity = new Vector2(rb.linearVelocity.x, doubleJumpForce);
        hasDoubleJumped = true;
    }
    
    void WallJump()
    {
        rb.linearVelocity = new Vector2(wallJumpDirection.x * wallJumpForce * -facingDirection, wallJumpDirection.y * wallJumpForce);
        isWallSliding = false;
        hasDoubleJumped = false;
    }
    
    void StartDash()
    {
        isDashing = true;
        canDash = false;
        dashCooldownTimer = dashCooldown;
        
        // Apply dash force
        rb.linearVelocity = new Vector2(facingDirection * dashForce, 0);
        
        // End dash after a short time
        Invoke("EndDash", 0.2f);
    }
    
    void EndDash()
    {
        isDashing = false;
    }
    
    void CheckWallSlide()
    {
        if (!isGrounded && canWallJump)
        {
            RaycastHit2D hit = Physics2D.Raycast(transform.position, Vector2.right * facingDirection, wallCheckDistance, LayerMask.GetMask("Ground"));
            
            if (hit.collider != null)
            {
                isWallSliding = true;
            }
            else
            {
                isWallSliding = false;
            }
        }
        else
        {
            isWallSliding = false;
        }
    }

    void OnCollisionEnter2D(Collision2D collision)
    {
        // Check if player is standing on something
        if (collision.gameObject.CompareTag("Ground") ||
            (collision.contacts.Length > 0 && collision.contacts[0].normal.y > 0.5f))
        {
            isGrounded = true;
            hasDoubleJumped = false;
        }
    }
    
    void OnCollisionExit2D(Collision2D collision)
    {
        // Check if player has left the ground
        if (collision.gameObject.CompareTag("Ground"))
        {
            isGrounded = false;
        }
    }
    
    // Public accessor methods
    public bool IsGrounded() { return isGrounded; }
    public bool IsWallSliding() { return isWallSliding; }
    public bool IsDashing() { return isDashing; }
    public int GetFacingDirection() { return facingDirection; }
}