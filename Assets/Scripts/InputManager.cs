using UnityEngine;
using UnityEngine.InputSystem;

public class InputManager : MonoBehaviour
{
    public static InputManager Instance { get; private set; }
    
    [Header("Input Assets")]
    [Tooltip("Reference to the Input Actions asset")]
    public InputActionAsset inputActions;
    
    [Header("Debug")]
    public bool showDebugInfo = false;
    
    // Input action references
    private InputActionMap playerActionMap;
    
    private void Awake()
    {
        // Singleton pattern
        if (Instance == null)
        {
            Instance = this;
            DontDestroyOnLoad(gameObject);
        }
        else
        {
            Destroy(gameObject);
            return;
        }
        
        // Initialize input system
        InitializeInputSystem();
    }
    
    private void InitializeInputSystem()
    {
        if (inputActions == null)
        {
            Debug.LogError("Input Actions asset is not assigned to InputManager!");
            return;
        }
        
        // Get the player action map
        playerActionMap = inputActions.FindActionMap("Player");
        
        if (playerActionMap == null)
        {
            Debug.LogError("Could not find 'Player' action map in the Input Actions asset!");
            return;
        }
        
        // Enable the player action map
        playerActionMap.Enable();
        
        if (showDebugInfo)
        {
            Debug.Log("Input System initialized successfully!");
            
            // Log all available devices
            var devices = InputSystem.devices;
            foreach (var device in devices)
            {
                Debug.Log($"Connected device: {device.name} ({device.deviceId}) - {device.description}");
            }
        }
    }
    
    private void OnEnable()
    {
        // Enable input actions when this component is enabled
        if (playerActionMap != null)
        {
            playerActionMap.Enable();
        }
    }
    
    private void OnDisable()
    {
        // Disable input actions when this component is disabled
        if (playerActionMap != null)
        {
            playerActionMap.Disable();
        }
    }
    
    // Method to check if a gamepad is connected
    public bool IsGamepadConnected()
    {
        var gamepads = Gamepad.all;
        return gamepads.Count > 0;
    }
    
    // Method to get the first connected gamepad
    public Gamepad GetGamepad()
    {
        var gamepads = Gamepad.all;
        return gamepads.Count > 0 ? gamepads[0] : null;
    }
    
    // Method to check if an Xbox controller is connected
    public bool IsXboxControllerConnected()
    {
        var gamepad = GetGamepad();
        if (gamepad == null) return false;
        
        string deviceName = gamepad.name.ToLower();
        return deviceName.Contains("xbox") || deviceName.Contains("xb");
    }
} 