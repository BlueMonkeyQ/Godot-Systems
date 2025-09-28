# Attack System

## Table of Contents
- [Project Overview](#project-overview)
- [Attack System Overview](#attack-system-overview)
  - [Data-Driven Architecture](#data-driven-architecture)
  - [JSON Attack Configuration](#json-attack-configuration)
- [Attack State Integration](#attack-state-integration)
  - [State Machine Integration](#state-machine-integration)
  - [Attack Execution Flow](#attack-execution-flow)
  - [Animation and Hitbox Management](#animation-and-hitbox-management)
- [Combo System Architecture](#combo-system-architecture)
  - [Input Sequence Tracking](#input-sequence-tracking)
  - [Combo Window Timing](#combo-window-timing)
  - [Combo Reset Logic](#combo-reset-logic)
- [Sequence Checking Logic](#sequence-checking-logic)
  - [Attack Matching Algorithm](#attack-matching-algorithm)
  - [Priority System](#priority-system)
  - [Sequence Examples](#sequence-examples)
- [Attack Data Structure](#attack-data-structure)
  - [JSON Schema](#json-schema)
  - [Attack Properties](#attack-properties)
  - [Combat Style Organization](#combat-style-organization)
- [Hitbox System](#hitbox-system)
  - [Hitbox Types](#hitbox-types)
  - [Dynamic Positioning](#dynamic-positioning)
  - [Collision Management](#collision-management)
- [Collision Layers and Masks](#collision-layers-and-masks)
  - [Godot Physics System Overview](#godot-physics-system-overview)
  - [Hurtbox Configuration](#hurtbox-configuration)
  - [Detection Logic](#detection-logic)
  - [Integration with Attack System](#integration-with-attack-system)
- [Signal System](#signal-system)
  - [Attack Executed Signal](#attack-executed-signal)
  - [Component Communication](#component-communication)

## Project Overview

The Attack System is a comprehensive, data-driven combat framework that enables complex combo sequences, multiple attack types, and dynamic hitbox management. The system integrates seamlessly with the existing State Machine architecture to provide responsive and flexible combat mechanics.

## Attack System Overview

### Data-Driven Architecture

The Attack System loads all attack configurations from `attacks.json`, allowing for easy modification and expansion of combat moves without code changes. This approach enables:

* **Runtime Configuration**: Attacks can be modified without recompilation
* **Easy Balancing**: Damage multipliers, effects, and timing can be adjusted in JSON
* **Extensible Design**: New attacks and combat styles can be added through data files
* **Designer-Friendly**: Non-programmers can create and modify attacks

```gd
# Attack data is loaded at runtime from JSON
func _ready():
    var file = FileAccess.open("res://Attack System/attacks.json", FileAccess.READ)
    if file:
        var json_string = file.get_as_text()
        var json = JSON.new()
        var parse_result = json.parse(json_string)
        if parse_result == OK:
            attack_data = json.data
```

### JSON Attack Configuration

The system organizes attacks by combat style (currently "melee") and supports multiple attack properties for each move:

```json
{
    "melee": [
        {
            "name": "Single Strike",
            "sequence": ["primary"],
            "secondaryKey": null,
            "damageMult": 1,
            "effects": {},
            "hitboxType": "slash",
            "endCombo": false,
            "animation": "attack"
        }
    ]
}
```

## Attack State Integration

### State Machine Integration

The `AttackState` class extends `PlayerState` and integrates with the existing state machine architecture. When the player enters the attack state:

1. **Signal Connection**: Connects to the `attack_executed` signal from the attack system
2. **Input Processing**: Executes attack with "primary" input sequence
3. **State Management**: Handles transitions back to idle state after attack completion

```gd
func enter() -> void:
    if not player.attack_system.attack_executed.is_connected(_on_attack_executed):
        player.attack_system.attack_executed.connect(_on_attack_executed)
    
    player.hurtbox_2d.disabled = true
    player.velocity = Vector2.ZERO
    player.current_direction = player.update_attack_direction()
    player.attack_system.execute_attack("primary")
```

### Attack Execution Flow

The attack execution follows this sequence:

1. **Input Received**: Player presses attack button, triggering state change to "attack"
2. **Sequence Processing**: Attack system adds input to `current_combo_sequence`
3. **Attack Matching**: System searches for matching attack in loaded data
4. **Signal Emission**: `attack_executed` signal fired with attack data
5. **Visual Setup**: Animation plays and hitbox is configured
6. **Combo Window**: After animation, combo window opens for potential follow-ups

### Animation and Hitbox Management

The attack state handles both visual and collision aspects:

```gd
func _on_attack_executed(attack_data: Dictionary):
    var animation_name = attack_data.get("animation", "idle")
    player.animation_controller.update_animation(animation_name)
    
    setup_attack_hurtbox(attack_data)
    player.hurtbox.monitoring = true
    player.hurtbox_2d.disabled = false
```

## Combo System Architecture

### Input Sequence Tracking

The combo system tracks player inputs in the `current_combo_sequence` array. Each attack input is appended to this sequence, allowing for complex multi-hit combinations:

```gd
var current_combo_sequence: Array = []

func execute_attack(input_sequence: String) -> void:
    current_combo_sequence.append(input_sequence)
    var attack = find_matching_attack()
    # Process attack or reset combo if no match found
```

**Example Sequences:**
* Single attack: `["primary"]`
* Double combo: `["primary", "primary"]`
* Triple combo: `["primary", "primary", "primary"]`

### Combo Window Timing

The system uses a timing window to determine when combos can continue:

```gd
var combo_cooldown: float = 0.0
var combo_duration: float = 1.5
var is_combo_active: bool = false

func _process(delta):
    if is_combo_active:
        combo_cooldown -= delta
        if combo_cooldown <= 0.0:
            reset_combo()
```

* **Combo Duration**: 1.5 seconds window for follow-up attacks
* **Active Tracking**: `is_combo_active` flag manages combo state
* **Automatic Reset**: Combo resets when window expires

### Combo Reset Logic

Combos are reset in several scenarios:

1. **Timer Expiration**: When `combo_cooldown` reaches zero
2. **No Match Found**: When input sequence doesn't match any attack
3. **End Combo Flag**: When attack has `"endCombo": true`
4. **Manual Reset**: Through explicit `reset_combo()` calls

```gd
func reset_combo() -> void:
    is_combo_active = false
    current_combo_sequence.clear()
    print("Combo Reset")
```

## Sequence Checking Logic

### Attack Matching Algorithm

The system uses a two-pass algorithm to find matching attacks:

1. **First Pass**: Check attacks with secondary key requirements
2. **Second Pass**: Check regular sequence-only attacks

This ensures that special attacks (like dash strikes) take priority over basic attacks when conditions are met.

### Priority System

**High Priority - Secondary Key Attacks:**
```gd
# First priority: Check for attacks with secondary keys
for attack in attack_data[combat_style]:
    if sequence_matches and attack.has("secondaryKey") and attack["secondaryKey"] != null:
        var secondary_key = attack["secondaryKey"]
        if Input.is_action_pressed(secondary_key):
            return attack
```

**Low Priority - Regular Attacks:**
```gd
# Second priority: Check for regular sequence-only attacks
for attack in attack_data[combat_style]:
    if sequence_matches and (not attack.has("secondaryKey") or attack["secondaryKey"] == null):
        return attack
```

### Sequence Examples

**Basic Combo Chain:**
1. `["primary"]` → "Single Strike" (slash, continues combo)
2. `["primary", "primary"]` → "Second Strike" (slash, continues combo)
3. `["primary", "primary", "primary"]` → "Third Strike" (thrust, ends combo)

**Special Attack:**
* `["primary"]` + Run Key Held → "Dash Strike" (thrust, ends combo)

The Dash Strike takes priority over Single Strike when the run key is pressed, demonstrating the secondary key system.

## Attack Data Structure

### JSON Schema

Each attack in the JSON file follows this structure:

```json
{
    "name": "Attack Name",
    "sequence": ["input1", "input2"],
    "secondaryKey": "key_name_or_null",
    "damageMult": 1.0,
    "effects": {},
    "hitboxType": "slash_or_thrust",
    "endCombo": true_or_false,
    "animation": "animation_name"
}
```

### Attack Properties

| Property | Type | Description |
|----------|------|-------------|
| `name` | String | Display name for the attack |
| `sequence` | Array | Input sequence required to trigger |
| `secondaryKey` | String/null | Additional key requirement (e.g., "run") |
| `damageMult` | Number | Damage multiplier for the attack |
| `effects` | Object | Additional effects (currently unused) |
| `hitboxType` | String | "slash" or "thrust" for hitbox shape |
| `endCombo` | Boolean | Whether this attack ends the combo chain |
| `animation` | String | Animation name to play |

### Combat Style Organization

Attacks are organized by combat style in the JSON:

```json
{
    "melee": [ /* melee attacks */ ],
    "ranged": [ /* future ranged attacks */ ],
    "magic": [ /* future magic attacks */ ]
}
```

Currently, only "melee" style is implemented, but the structure supports easy expansion.

## Hitbox System

### Hitbox Types

The system supports two primary hitbox types:

**Slash Hitbox:**
* **Shape**: Wide and short (30x60 pixels)
* **Use Case**: Sweeping attacks, crowd control
* **Positioning**: Width extends perpendicular to attack direction

**Thrust Hitbox:**
* **Shape**: Long and narrow (60x30 pixels)
* **Use Case**: Piercing attacks, single target focus
* **Positioning**: Length extends along attack direction

### Dynamic Positioning

Hitboxes are dynamically positioned based on the player's attack direction:

```gd
func setup_slash_hurtbox(attack_angle: float) -> void:
    var cos_angle = cos(attack_angle)
    var sin_angle = sin(attack_angle)
    
    var hitbox_width = 30
    var hitbox_height = 60
    
    player.hurtbox_2d.rotation = attack_angle
    
    var center_x = cos_angle * (hitbox_width / 2)
    var center_y = sin_angle * (hitbox_width / 2)
    player.hurtbox.position = Vector2(center_x, center_y)
```

### Collision Management

The hitbox system manages collision states throughout the attack:

1. **Pre-Attack**: Hitbox disabled and invisible
2. **During Attack**: Hitbox enabled, visible, and monitoring collisions
3. **Post-Attack**: Hitbox disabled and hidden until next attack

## Collision Layers and Masks

### Godot Physics System Overview

Godot's collision system uses layers and masks to determine which objects can interact with each other:

* **Collision Layer**: Defines which layer(s) an object exists on
* **Collision Mask**: Defines which layer(s) an object can detect/interact with
* **Layer Numbers**: 32 available layers (1-32) that can be named for clarity

### Hurtbox Configuration

The `Hurtbox` Area2D node uses specific collision settings to detect valid targets:

```gd
# Hurtbox collision configuration in scene
# Layer: Player Attack (Layer 2)
# Mask: Enemy (Layer 3), Environment (Layer 4)
```

**Layer Assignment:**
* **Layer 1**: Player/Character bodies
* **Layer 2**: Player attack hitboxes
* **Layer 3**: Enemy bodies and hurtboxes
* **Layer 4**: Interactive environment objects

### Detection Logic

The collision system ensures proper attack targeting:

```gd
func OnCollision(_area: Area2D) -> void:
    # Only triggers when Hurtbox (Layer 2) detects objects on Mask layers (3, 4)
    # Prevents self-collision and friendly fire
    pass
```

**Collision Rules:**
1. **Player attacks** (Layer 2) can hit **enemies** (Layer 3)
2. **Player attacks** (Layer 2) can hit **environment** (Layer 4)
3. **Player attacks** (Layer 2) cannot hit **player** (Layer 1)

### Integration with Attack System

The collision configuration works seamlessly with the attack execution flow:

1. **Attack Initiated**: `Hurtbox` monitoring enabled in `AttackState`
2. **Collision Detection**: Area2D detects objects on configured mask layers
3. **Damage Processing**: `OnCollision` method processes valid targets
4. **Attack Cleanup**: Monitoring disabled after attack completion

```gd
# Attack state enables collision detection
player.hurtbox.monitoring = true
player.hurtbox_2d.disabled = false

# Collision system automatically filters valid targets
# based on layer/mask configuration
```

This layer-based approach ensures attacks only affect intended targets while maintaining clean separation between different object types in the game world.

## Signal System

### Attack Executed Signal

The core communication mechanism uses Godot's signal system:

```gd
signal attack_executed(attack_data)  # Emitted when attack is found and executed
```

This signal carries the complete attack data dictionary, allowing receiving components to access all attack properties.

### Component Communication

**Signal Flow:**
1. **Attack System** → Emits `attack_executed` with attack data
2. **Attack State** → Receives signal, handles animation and hitbox setup
3. **Animation Controller** → Updates sprite animation based on attack data
4. **Hitbox System** → Configures collision shape and positioning

**Connection Management:**
```gd
# Connect signal when entering attack state
if not player.attack_system.attack_executed.is_connected(_on_attack_executed):
    player.attack_system.attack_executed.connect(_on_attack_executed)

# Disconnect when exiting to prevent memory leaks
if player.attack_system.attack_executed.is_connected(_on_attack_executed):
    player.attack_system.attack_executed.disconnect(_on_attack_executed)
```

This decoupled approach allows for easy extension and modification of attack behaviors without changing core system code.
