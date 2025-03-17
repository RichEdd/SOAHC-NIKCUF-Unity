using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class PlayerCombat : MonoBehaviour
{
    [Header("Attack Settings")]
    public float attackCooldown = 0.5f;
    public Transform attackPoint;
    public float attackRange = 0.5f;
    public LayerMask enemyLayers;
    public int attackDamage = 20;
    
    [Header("Combo Settings")]
    public bool enableCombos = true;
    public int maxComboCount = 3;
    public float comboTimeWindow = 1.0f;
    
    [Header("Elemental Powers")]
    public bool enableElementalPowers = true;
    public enum ElementType { None, Fire, Ice, Lightning, Earth }
    public ElementType currentElement = ElementType.None;
    
    // Private variables
    private bool canAttack = true;
    private float attackCooldownTimer;
    private int currentComboCount = 0;
    private float lastAttackTime;
    private PlayerController playerController;
    
    // Input variables
    private bool attackPressed;
    private Vector2 elementSelectInput;
    
    // References
    private Animator animator;
    private PlayerInput playerInput;
    private InputAction attackAction;
    private InputAction elementSelectAction;
    
    void Awake()
    {
        // Set up Input System
        playerInput = GetComponent<PlayerInput>();
        if (playerInput != null)
        {
            attackAction = playerInput.actions.FindAction("Attack");
            elementSelectAction = playerInput.actions.FindAction("ElementSelect");
            
            // Set up callbacks
            if (attackAction != null)
                attackAction.performed += ctx => OnAttackInput(true);
            if (attackAction != null)
                attackAction.canceled += ctx => OnAttackInput(false);
            if (elementSelectAction != null)
                elementSelectAction.performed += ctx => OnElementSelectInput(ctx.ReadValue<Vector2>());
        }
    }
    
    void Start()
    {
        playerController = GetComponent<PlayerController>();
        animator = GetComponent<Animator>();
    }
    
    void Update()
    {
        // Attack cooldown timer
        if (!canAttack)
        {
            attackCooldownTimer -= Time.deltaTime;
            if (attackCooldownTimer <= 0)
            {
                canAttack = true;
            }
        }
        
        // Reset combo if time window has passed
        if (enableCombos && Time.time - lastAttackTime > comboTimeWindow)
        {
            currentComboCount = 0;
        }
        
        // Process attack input (for keyboard/mouse fallback)
        if (Input.GetMouseButtonDown(0) && canAttack && !playerController.IsDashing())
        {
            OnAttackInput(true);
        }
        
        // Process element selection input (for keyboard fallback)
        if (enableElementalPowers)
        {
            if (Input.GetKeyDown(KeyCode.Alpha1))
                currentElement = ElementType.Fire;
            else if (Input.GetKeyDown(KeyCode.Alpha2))
                currentElement = ElementType.Ice;
            else if (Input.GetKeyDown(KeyCode.Alpha3))
                currentElement = ElementType.Lightning;
            else if (Input.GetKeyDown(KeyCode.Alpha4))
                currentElement = ElementType.Earth;
            else if (Input.GetKeyDown(KeyCode.Alpha0))
                currentElement = ElementType.None;
        }
    }
    
    void OnAttackInput(bool pressed)
    {
        attackPressed = pressed;
        
        if (pressed && canAttack && !playerController.IsDashing())
        {
            Attack();
        }
    }
    
    void OnElementSelectInput(Vector2 input)
    {
        elementSelectInput = input;
        
        if (!enableElementalPowers)
            return;
            
        // D-pad up
        if (input.y > 0.5f)
            currentElement = ElementType.Fire;
        // D-pad right
        else if (input.x > 0.5f)
            currentElement = ElementType.Lightning;
        // D-pad down
        else if (input.y < -0.5f)
            currentElement = ElementType.Earth;
        // D-pad left
        else if (input.x < -0.5f)
            currentElement = ElementType.Ice;
    }
    
    void Attack()
    {
        // Set attack on cooldown
        canAttack = false;
        attackCooldownTimer = attackCooldown;
        
        // Update combo count
        if (enableCombos)
        {
            currentComboCount = (currentComboCount % maxComboCount) + 1;
            lastAttackTime = Time.time;
        }
        
        // Play attack animation (if animator exists)
        if (animator != null)
        {
            animator.SetTrigger("Attack");
            animator.SetInteger("ComboCount", currentComboCount);
        }
        
        // Detect enemies in range
        Collider2D[] hitEnemies = Physics2D.OverlapCircleAll(attackPoint.position, attackRange, enemyLayers);
        
        // Apply damage to enemies
        foreach (Collider2D enemy in hitEnemies)
        {
            // Calculate damage based on combo and element
            int finalDamage = CalculateDamage();
            
            // Apply damage to enemy
            IDamageable damageable = enemy.GetComponent<IDamageable>();
            if (damageable != null)
            {
                damageable.TakeDamage(finalDamage, currentElement);
            }
            
            // Apply elemental effects
            ApplyElementalEffects(enemy);
        }
    }
    
    int CalculateDamage()
    {
        // Base damage
        int damage = attackDamage;
        
        // Combo multiplier
        if (enableCombos && currentComboCount > 1)
        {
            damage = (int)(damage * (1 + (currentComboCount - 1) * 0.25f));
        }
        
        // Elemental bonus
        if (enableElementalPowers && currentElement != ElementType.None)
        {
            damage = (int)(damage * 1.2f);
        }
        
        return damage;
    }
    
    void ApplyElementalEffects(Collider2D enemy)
    {
        if (!enableElementalPowers || currentElement == ElementType.None)
            return;
            
        IElementalEffect elementalEffect = enemy.GetComponent<IElementalEffect>();
        if (elementalEffect != null)
        {
            switch (currentElement)
            {
                case ElementType.Fire:
                    elementalEffect.ApplyFireEffect(3.0f, 5);
                    break;
                case ElementType.Ice:
                    elementalEffect.ApplyIceEffect(2.0f, 0.5f);
                    break;
                case ElementType.Lightning:
                    elementalEffect.ApplyLightningEffect(1.0f, 10);
                    break;
                case ElementType.Earth:
                    elementalEffect.ApplyEarthEffect(1.5f, 15);
                    break;
            }
        }
    }
    
    // Draw attack range gizmo for debugging
    void OnDrawGizmosSelected()
    {
        if (attackPoint == null)
            return;
            
        Gizmos.color = Color.red;
        Gizmos.DrawWireSphere(attackPoint.position, attackRange);
    }
    
    // Public accessor methods
    public ElementType GetCurrentElement() { return currentElement; }
}

// Interface for objects that can take damage
public interface IDamageable
{
    void TakeDamage(int damage, PlayerCombat.ElementType elementType);
}

// Interface for objects that can have elemental effects applied
public interface IElementalEffect
{
    void ApplyFireEffect(float duration, int damagePerSecond);
    void ApplyIceEffect(float duration, float slowFactor);
    void ApplyLightningEffect(float duration, int chainDamage);
    void ApplyEarthEffect(float duration, int defenseReduction);
} 