using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class PlayerHealth : MonoBehaviour
{
    [Header("Health Settings")]
    public int maxHealth = 100;
    public int currentHealth;
    public Image healthBar;
    
    [Header("Invincibility Settings")]
    public float invincibilityDuration = 1f;
    public float flashDuration = 0.1f;
    public bool isInvincible = false;
    
    [Header("Knockback Settings")]
    public float knockbackForce = 10f;
    public float knockbackDuration = 0.25f;
    
    // References
    private Rigidbody2D rb;
    private SpriteRenderer spriteRenderer;
    private PlayerController playerController;
    
    // Private variables
    private float invincibilityTimer;
    private bool isKnockedBack = false;
    
    void Start()
    {
        currentHealth = maxHealth;
        rb = GetComponent<Rigidbody2D>();
        spriteRenderer = GetComponent<SpriteRenderer>();
        playerController = GetComponent<PlayerController>();
        
        // Update health bar if it exists
        UpdateHealthBar();
    }
    
    void Update()
    {
        // Process invincibility
        if (isInvincible)
        {
            invincibilityTimer -= Time.deltaTime;
            
            // Flash the player sprite
            if (invincibilityTimer % (flashDuration * 2) < flashDuration)
            {
                spriteRenderer.color = new Color(1, 1, 1, 0.5f);
            }
            else
            {
                spriteRenderer.color = Color.white;
            }
            
            // End invincibility when timer runs out
            if (invincibilityTimer <= 0)
            {
                isInvincible = false;
                spriteRenderer.color = Color.white;
            }
        }
    }
    
    public void TakeDamage(int damage)
    {
        // Don't take damage if invincible
        if (isInvincible)
            return;
            
        // Apply damage
        currentHealth -= damage;
        
        // Update health bar
        UpdateHealthBar();
        
        // Apply invincibility
        isInvincible = true;
        invincibilityTimer = invincibilityDuration;
        
        // Apply knockback
        StartCoroutine(ApplyKnockback());
        
        // Check if dead
        if (currentHealth <= 0)
        {
            Die();
        }
    }
    
    IEnumerator ApplyKnockback()
    {
        isKnockedBack = true;
        
        // Get the direction from the closest enemy
        Vector2 knockbackDirection = GetKnockbackDirection();
        
        // Apply knockback force
        rb.velocity = Vector2.zero;
        rb.AddForce(knockbackDirection * knockbackForce, ForceMode2D.Impulse);
        
        // Wait for knockback duration
        yield return new WaitForSeconds(knockbackDuration);
        
        isKnockedBack = false;
    }
    
    Vector2 GetKnockbackDirection()
    {
        // Find the closest enemy
        GameObject[] enemies = GameObject.FindGameObjectsWithTag("Enemy");
        float closestDistance = float.MaxValue;
        Vector2 knockbackDirection = Vector2.right * -playerController.GetFacingDirection();
        
        foreach (GameObject enemy in enemies)
        {
            float distance = Vector2.Distance(transform.position, enemy.transform.position);
            if (distance < closestDistance)
            {
                closestDistance = distance;
                knockbackDirection = (transform.position - enemy.transform.position).normalized;
            }
        }
        
        // If no enemies found, knock back in the opposite direction of facing
        return knockbackDirection;
    }
    
    void UpdateHealthBar()
    {
        if (healthBar != null)
        {
            healthBar.fillAmount = (float)currentHealth / maxHealth;
        }
    }
    
    public void Heal(int amount)
    {
        currentHealth = Mathf.Min(currentHealth + amount, maxHealth);
        UpdateHealthBar();
    }
    
    void Die()
    {
        // Disable player controls
        playerController.enabled = false;
        
        // Play death animation or effect
        // You can add animation triggers here if you have an Animator
        
        // Disable physics
        rb.velocity = Vector2.zero;
        rb.isKinematic = true;
        GetComponent<Collider2D>().enabled = false;
        
        // Respawn or game over logic
        Invoke("Respawn", 2f);
    }
    
    void Respawn()
    {
        // Reset health
        currentHealth = maxHealth;
        UpdateHealthBar();
        
        // Reset position (you might want to use a spawn point)
        transform.position = Vector3.zero;
        
        // Re-enable components
        rb.isKinematic = false;
        GetComponent<Collider2D>().enabled = true;
        playerController.enabled = true;
    }
    
    // Public accessor methods
    public bool IsInvincible() { return isInvincible; }
    public bool IsKnockedBack() { return isKnockedBack; }
    public float GetHealthPercentage() { return (float)currentHealth / maxHealth; }
} 