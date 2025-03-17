using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Enemy : MonoBehaviour, IDamageable, IElementalEffect
{
    [Header("Stats")]
    public int maxHealth = 100;
    public float moveSpeed = 3f;
    
    [Header("Attack")]
    public int attackDamage = 10;
    public float attackRange = 1.5f;
    public float attackCooldown = 1.5f;
    
    [Header("Detection")]
    public float detectionRange = 10f;
    public LayerMask playerLayer;
    
    // Private variables
    private int currentHealth;
    private bool canAttack = true;
    private float attackCooldownTimer;
    private Transform player;
    private Rigidbody2D rb;
    private SpriteRenderer spriteRenderer;
    
    // Elemental effect variables
    private bool isOnFire;
    private bool isFrozen;
    private bool isShocked;
    private bool isWeakened;
    private float fireTimer;
    private float iceTimer;
    private float lightningTimer;
    private float earthTimer;
    private int fireDamagePerSecond;
    private float iceSlowFactor;
    private int lightningChainDamage;
    private int earthDefenseReduction;
    
    // References
    private Animator animator;
    
    void Start()
    {
        currentHealth = maxHealth;
        rb = GetComponent<Rigidbody2D>();
        spriteRenderer = GetComponent<SpriteRenderer>();
        animator = GetComponent<Animator>();
        
        // Find player
        player = GameObject.FindGameObjectWithTag("Player")?.transform;
    }
    
    void Update()
    {
        // Attack cooldown
        if (!canAttack)
        {
            attackCooldownTimer -= Time.deltaTime;
            if (attackCooldownTimer <= 0)
            {
                canAttack = true;
            }
        }
        
        // Process elemental effects
        ProcessElementalEffects();
        
        // Only process AI if not frozen
        if (!isFrozen && player != null)
        {
            // Check if player is in detection range
            float distanceToPlayer = Vector2.Distance(transform.position, player.position);
            
            if (distanceToPlayer <= detectionRange)
            {
                // Move towards player if not in attack range
                if (distanceToPlayer > attackRange)
                {
                    MoveTowardsPlayer();
                }
                // Attack if in range and can attack
                else if (canAttack)
                {
                    Attack();
                }
            }
        }
    }
    
    void MoveTowardsPlayer()
    {
        // Calculate direction to player
        Vector2 direction = (player.position - transform.position).normalized;
        
        // Apply movement (with ice slow effect if applicable)
        float currentSpeed = isFrozen ? moveSpeed * (1 - iceSlowFactor) : moveSpeed;
        rb.linearVelocity = direction * currentSpeed;
        
        // Flip sprite based on movement direction
        if (direction.x > 0)
        {
            spriteRenderer.flipX = false;
        }
        else if (direction.x < 0)
        {
            spriteRenderer.flipX = true;
        }
        
        // Play animation if animator exists
        if (animator != null)
        {
            animator.SetBool("IsMoving", true);
        }
    }
    
    void Attack()
    {
        // Set attack on cooldown
        canAttack = false;
        attackCooldownTimer = attackCooldown;
        
        // Play attack animation if animator exists
        if (animator != null)
        {
            animator.SetTrigger("Attack");
        }
        
        // Detect player in attack range
        Collider2D playerCollider = Physics2D.OverlapCircle(transform.position, attackRange, playerLayer);
        
        if (playerCollider != null)
        {
            // Get player health component and apply damage
            PlayerHealth playerHealth = playerCollider.GetComponent<PlayerHealth>();
            if (playerHealth != null)
            {
                playerHealth.TakeDamage(attackDamage);
            }
        }
    }
    
    void ProcessElementalEffects()
    {
        // Process fire effect (damage over time)
        if (isOnFire)
        {
            fireTimer -= Time.deltaTime;
            
            // Apply fire damage every second
            if (Mathf.FloorToInt(fireTimer) < Mathf.FloorToInt(fireTimer + Time.deltaTime))
            {
                TakeDamage(fireDamagePerSecond, PlayerCombat.ElementType.None);
            }
            
            if (fireTimer <= 0)
            {
                isOnFire = false;
            }
        }
        
        // Process ice effect (slow movement)
        if (isFrozen)
        {
            iceTimer -= Time.deltaTime;
            if (iceTimer <= 0)
            {
                isFrozen = false;
            }
        }
        
        // Process lightning effect (periodic chain damage)
        if (isShocked)
        {
            lightningTimer -= Time.deltaTime;
            
            // Chain lightning to nearby enemies every 0.5 seconds
            if (Mathf.FloorToInt(lightningTimer * 2) < Mathf.FloorToInt((lightningTimer + Time.deltaTime) * 2))
            {
                ChainLightning();
            }
            
            if (lightningTimer <= 0)
            {
                isShocked = false;
            }
        }
        
        // Process earth effect (defense reduction)
        if (isWeakened)
        {
            earthTimer -= Time.deltaTime;
            if (earthTimer <= 0)
            {
                isWeakened = false;
                earthDefenseReduction = 0;
            }
        }
    }
    
    void ChainLightning()
    {
        // Find nearby enemies within 3 units
        Collider2D[] nearbyEnemies = Physics2D.OverlapCircleAll(transform.position, 3f);
        
        foreach (Collider2D enemyCollider in nearbyEnemies)
        {
            // Skip self
            if (enemyCollider.gameObject == gameObject)
                continue;
                
            // Apply chain damage to other enemies
            Enemy enemy = enemyCollider.GetComponent<Enemy>();
            if (enemy != null)
            {
                enemy.TakeDamage(lightningChainDamage, PlayerCombat.ElementType.Lightning);
            }
        }
    }
    
    // IDamageable implementation
    public void TakeDamage(int damage, PlayerCombat.ElementType elementType)
    {
        // Apply defense reduction from earth effect
        if (isWeakened)
        {
            damage += earthDefenseReduction;
        }
        
        // Apply damage
        currentHealth -= damage;
        
        // Play hit animation if animator exists
        if (animator != null)
        {
            animator.SetTrigger("Hit");
        }
        
        // Flash red
        StartCoroutine(FlashRed());
        
        // Check if dead
        if (currentHealth <= 0)
        {
            Die();
        }
    }
    
    IEnumerator FlashRed()
    {
        spriteRenderer.color = Color.red;
        yield return new WaitForSeconds(0.1f);
        spriteRenderer.color = Color.white;
    }
    
    void Die()
    {
        // Play death animation if animator exists
        if (animator != null)
        {
            animator.SetTrigger("Die");
            
            // Disable components
            rb.linearVelocity = Vector2.zero;
            GetComponent<Collider2D>().enabled = false;
            this.enabled = false;
            
            // Destroy after animation
            Destroy(gameObject, 1f);
        }
        else
        {
            // Destroy immediately if no animator
            Destroy(gameObject);
        }
    }
    
    // IElementalEffect implementation
    public void ApplyFireEffect(float duration, int damagePerSecond)
    {
        isOnFire = true;
        fireTimer = duration;
        fireDamagePerSecond = damagePerSecond;
    }
    
    public void ApplyIceEffect(float duration, float slowFactor)
    {
        isFrozen = true;
        iceTimer = duration;
        iceSlowFactor = slowFactor;
    }
    
    public void ApplyLightningEffect(float duration, int chainDamage)
    {
        isShocked = true;
        lightningTimer = duration;
        lightningChainDamage = chainDamage;
    }
    
    public void ApplyEarthEffect(float duration, int defenseReduction)
    {
        isWeakened = true;
        earthTimer = duration;
        earthDefenseReduction = defenseReduction;
    }
    
    // Draw gizmos for debugging
    void OnDrawGizmosSelected()
    {
        // Detection range
        Gizmos.color = Color.yellow;
        Gizmos.DrawWireSphere(transform.position, detectionRange);
        
        // Attack range
        Gizmos.color = Color.red;
        Gizmos.DrawWireSphere(transform.position, attackRange);
    }
} 