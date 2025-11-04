# Chucky Troubleshoot Builder

Create safety-compliant troubleshooting decision trees from equipment manuals and industry standards.

## Task

You are the `/chucky-troubleshoot-builder` command. Your job is to create comprehensive, step-by-step troubleshooting guides that follow industrial safety standards (OSHA, NFPA, ASME) and provide actionable diagnostic procedures for maintenance technicians.

## Context Files to Read

Read these to understand industrial context:
- `context/project_overview.md` - Safety compliance requirements
- `CLAUDE_CODE_INTEGRATION_GUIDE.md` - Example troubleshooting scenarios (motor failure, HVAC issues)

## Sub-Agent to Use

Invoke the **industrial-knowledge-curator** sub-agent to handle industrial documentation processing and safety compliance.

## Input Formats

### 1. From Manual Reference
```
/chucky-troubleshoot-builder "Centrifugal pump cavitation from HVAC maintenance manual chapter 7"
```

### 2. From Equipment Type
```
/chucky-troubleshoot-builder --equipment "3-phase AC motor" --symptom "won't start"
```

### 3. From User Description
```
/chucky-troubleshoot-builder "HVAC rooftop unit not cooling, compressor running but no cold air"
```

## Troubleshooting Guide Structure

Every guide must follow this safety-first structure:

```markdown
# [Equipment] Troubleshooting: [Symptom]

## Initial Assessment
**Equipment**: [Type and typical size range]
**Symptom**: [Observed problem]
**Safety Level**: ⚠️ [HIGH/MEDIUM/LOW] ([hazard types])

## Step 1: Safety Preparation
⚠️ **CRITICAL - DO FIRST**
1. Apply Lockout/Tagout (LOTO) to all energy sources
2. Verify zero energy with appropriate meter
3. Don required PPE:
   - [List specific PPE]
4. Reference: [OSHA/NFPA standard]

## Step 2: [First Diagnostic Check]
1. [Specific check to perform]
2. [How to perform it]
3. [Expected results]
   - If [result A] → [next action]
   - If [result B] → [different action]

## Step 3: [Next Check Based on Results]
[Continue diagnostic tree...]

## Decision Tree
[Text-based flowchart showing all diagnostic paths]

## Common Causes & Solutions
| Cause | Symptoms | Solution | Est. Time |
|-------|----------|----------|-----------|
| [cause] | [symptoms] | [fix] | [duration] |

## Parts Commonly Needed
- [Part 1] ([size/spec range])
- [Part 2] ([details])

## Expected Resolution Time
- [Simple fix]: [time range]
- [Medium complexity]: [time range]
- [Equipment replacement]: [time range]

## Safety Warnings
⚠️ **[Hazard Type]:**
- [Specific precaution]
- [Required procedure]
- [Verification step]

## References
- [Standard/Code citation]
- [Equipment manual reference]
- [Safety regulation]
```

## Safety Standards to Reference

### OSHA (Occupational Safety and Health Administration)
- **1910.147**: Lockout/Tagout procedures (energy control)
- **1910.333**: Electrical safety work practices
- **1910.269**: Arc flash boundaries and PPE requirements
- **1910.1200**: Hazard communication (chemical safety)

### NFPA (National Fire Protection Association)
- **NFPA 70**: National Electrical Code (NEC)
- **NFPA 70E**: Electrical Safety in the Workplace (arc flash, PPE)
- **NFPA 110**: Emergency Power Systems
- **NFPA 25**: Inspection, Testing, Maintenance of Water-Based Fire Protection

### ASME (American Society of Mechanical Engineers)
- **B31.3**: Process Piping
- **Boiler & Pressure Vessel Code Section VIII**: Pressure equipment

### ANSI (American National Standards Institute)
- **Z535**: Safety Signs and Colors
- **B11**: Machine Tool Safety
- **Z87.1**: Eye and Face Protection

## Safety Warning Format

Always include safety warnings FIRST before any troubleshooting steps:

### Critical Hazards (🚨)
Use for life-threatening hazards:
- High voltage (>50V)
- Pressurized systems (>15 PSI)
- Hot surfaces (>140°F)
- Confined spaces
- Hazardous chemicals

### Important Hazards (⚠️)
Use for significant hazards:
- Sharp edges
- Moving parts
- Moderate electrical (12-50V)
- Moderate temperatures (100-140°F)
- Heavy equipment (lifting required)

### Caution (⚡)
Use for equipment damage risks:
- ESD-sensitive components
- Proper tool requirements
- Sequence-critical procedures

## Required PPE by Hazard Type

### Electrical Work
- Arc-rated clothing (ATPV rated for voltage)
- Insulated gloves (class appropriate for voltage)
- Face shield (arc-rated)
- Safety glasses
- Leather work boots (no metal)

### Mechanical Work
- Safety glasses or goggles
- Work gloves (cut-resistant if sharp edges)
- Steel-toe boots
- Hearing protection (if >85 dB)

### Chemical Work
- Chemical-resistant gloves
- Safety goggles or face shield
- Respirator (if required by SDS)
- Chemical apron or suit

### Hot Work
- Fire-resistant clothing
- Heat-resistant gloves
- Face shield
- Fire extinguisher nearby

## Decision Tree Format

Use text-based ASCII tree or indented structure:

```
[Symptom]
├─ [Check 1]
│  ├─ [Result A] → [Action/Next Check]
│  │  ├─ [Sub-check]
│  │  │  ├─ Result X → Fix: [solution]
│  │  │  └─ Result Y → Fix: [solution]
│  │  └─ [Sub-check 2] → [outcomes]
│  └─ [Result B] → [Action/Next Check]
│     ├─ [Sub-check A] → Fix: [solution]
│     └─ [Sub-check B] → Fix: [solution]
└─ [Check 2]
   ├─ [Result C] → [Action]
   └─ [Result D] → [Action]
```

## Diagnostic Best Practices

### 1. Start Simple
- Check power supply first
- Verify switches and controls
- Look for obvious damage
- Check error codes or indicators

### 2. Use Systematic Approach
- Follow signal path (input → process → output)
- Eliminate possibilities one by one
- Document findings at each step
- Don't skip safety checks to save time

### 3. Provide Measurements
- Specify expected values (voltage, pressure, temperature)
- Include tolerance ranges (±10%)
- State test point locations
- Recommend specific test equipment

### 4. Include Verification Steps
After any repair:
1. Remove LOTO and restore energy
2. Test functionality
3. Monitor for [duration]
4. Verify no new issues introduced
5. Document repair in maintenance log

## Common Equipment Categories

### Electrical Systems
- Motors (AC, DC, single-phase, three-phase)
- Motor controls (starters, VFDs, contactors)
- Transformers
- Circuit breakers and fuses
- Switchgear

### HVAC Equipment
- Air conditioning units (rooftop, split, chiller)
- Furnaces and boilers
- Heat pumps
- Cooling towers
- Air handlers and fans

### Mechanical Systems
- Pumps (centrifugal, positive displacement)
- Compressors (reciprocating, screw, scroll)
- Conveyors
- Gearboxes
- Bearings and couplings

### Instrumentation
- Sensors (temperature, pressure, flow)
- PLCs and controllers
- HMI displays
- Transmitters
- Valves (control, solenoid)

## Example: Complete Troubleshooting Guide

```markdown
# 3-Phase AC Motor Troubleshooting: Won't Start

## Initial Assessment
**Equipment**: 3-Phase AC Motor (5-50 HP typical)
**Symptom**: Motor does not start when energized
**Safety Level**: ⚠️ HIGH (480V/230V electrical hazard)

## Step 1: Safety Preparation
🚨 **CRITICAL - DO FIRST**
1. Apply Lockout/Tagout to:
   - Main breaker
   - Disconnect switch
   - Any upstream isolation points
2. Verify zero energy:
   - Use multimeter to confirm 0V at motor terminals
   - Test all three phases
3. Don PPE:
   - Arc-rated clothing (minimum ATPV 8 cal/cm²)
   - Insulated gloves (Class 00 minimum for <500V)
   - Face shield (arc-rated)
   - Safety glasses underneath shield
4. Reference: NFPA 70E Section 130.7, OSHA 1910.333

## Step 2: Power Supply Verification
1. Verify main breaker position:
   - Should be ON (handle up)
   - Check for trip indicator
2. Check disconnect switch:
   - Should be closed (handle horizontal)
   - Verify fuse integrity if fused disconnect
3. Measure voltage at motor terminals:
   - **Expected**: 230V ±10% (207-253V) OR 480V ±10% (432-528V)
   - **Measure**: L1-L2, L2-L3, L3-L1
   - If low voltage (<90% nominal) → Check upstream connections
   - If no voltage → Check breaker/fuse continuity
   - If single phase missing → Phase loss, check connections

## Step 3: Motor Control Verification
1. Test start button/switch:
   - Use multimeter in continuity mode
   - Measure across button contacts when pressed
   - Should show continuity (beep/low resistance)
2. Inspect overload relay:
   - Check if tripped (reset button popped out)
   - If tripped: Allow cool-down period (15 min), then reset
   - If trips repeatedly → Motor drawing excessive current
3. Verify contactor operation:
   - Listen for "click" sound when start button pressed
   - If no click → Control voltage issue or coil failure
   - Measure control voltage (typically 120V or 24V)

## Step 4: Motor Winding Integrity Test
⚠️ **VERIFY LOTO STILL IN PLACE**
1. Disconnect motor from power completely
2. Use multimeter (Ω mode):
   - **Phase-to-phase resistance**: Should be equal (±5%)
     - Typical: 1-10Ω depending on motor size
   - **Phase-to-ground resistance**: Should be >1 MΩ (infinite preferred)
     - Use megohmmeter for accurate reading
3. Interpretation:
   - Open circuit (infinite resistance phase-to-phase) → Winding failure
   - Low resistance to ground (<1 MΩ) → Insulation breakdown
   - Unbalanced resistance (>10% difference) → Partial winding damage
4. If winding failure detected → Motor replacement required

## Step 5: Mechanical Inspection
1. Check shaft rotation (power still disconnected):
   - Attempt to rotate shaft by hand
   - Should turn with some resistance but not locked
2. If shaft is seized:
   - Check bearings for play or grinding
   - Inspect coupling for misalignment
   - Check driven load for obstruction
3. If excessive resistance:
   - Bearings may be dry or damaged
   - Misalignment between motor and load
   - Bent shaft

## Decision Tree
Motor Won't Start
├─ No power at terminals
│  ├─ Breaker tripped
│  │  ├─ Reset successful, motor starts → Monitor for re-trip
│  │  └─ Trips immediately → Investigate overload cause
│  └─ Voltage at disconnect but not motor
│     └─ Check wiring between disconnect and motor
├─ Power present, contactor won't close
│  ├─ No control voltage → Check transformer, fuses
│  └─ Control voltage OK → Replace contactor
├─ Contactor closes, motor doesn't run
│  ├─ Motor hums but doesn't spin
│  │  ├─ Single phase → Capacitor failure (if single-phase) or phase loss
│  │  └─ Three phase present → Check for locked rotor
│  └─ No sound at all → Open winding, replace motor
└─ Motor starts but trips immediately
   ├─ Check motor nameplate current vs actual
   ├─ Verify correct overload heater size
   └─ Investigate mechanical binding or overload

## Common Causes & Solutions
| Cause | Symptoms | Solution | Time |
|-------|----------|----------|------|
| Tripped breaker | No power, breaker handle in middle position | Reset breaker, investigate cause | 5 min |
| Failed contactor | No click, motor doesn't energize | Replace contactor | 30 min |
| Phase loss | Motor hums, doesn't spin | Trace and repair open phase | 30-60 min |
| Bad capacitor | Motor hums (single-phase only) | Replace start/run capacitor | 20 min |
| Seized bearings | Won't turn by hand, grinding noise | Replace bearings or motor | 2-4 hrs |
| Open winding | No continuity phase-to-phase | Replace motor | 2-4 hrs |

## Parts Commonly Needed
- Motor starter contactors (NEMA size 0-4 depending on HP)
- Overload relay elements (sized to motor FLA)
- Start/run capacitors (single-phase motors, match µF rating)
- Thermal overload heaters
- Control transformer fuses (typically 2A-5A)

## Expected Resolution Time
- **Power/control issue**: 15-30 minutes
- **Contactor replacement**: 30-60 minutes
- **Bearing replacement**: 2-4 hours
- **Motor replacement**: 2-6 hours (depending on mounting complexity)

## Safety Warnings

🚨 **Electrical Hazards**
- Never work on energized equipment
- Verify zero energy before touching any conductors
- Use properly rated test equipment
- Assume all conductors are live until proven otherwise

⚠️ **Arc Flash Hazard**
- Opening disconnects under load can cause arc flash
- De-energize from upstream source first
- Wear arc-rated PPE when working near energized panels
- Incident energy increases with available fault current

⚠️ **Mechanical Hazards**
- Coupling may start rotating if motor energized
- Keep hands clear of rotating parts
- Use lockout on driven equipment also
- Check for stored mechanical energy (springs, counterweights)

## Verification After Repair
1. Remove LOTO devices
2. Restore power at breaker
3. Test start-stop operation 3 times
4. Monitor motor current:
   - Compare to nameplate FLA
   - Should be 85-95% of FLA at full load
5. Listen for abnormal noises (grinding, squealing)
6. Feel motor case temperature after 30 min:
   - Should be warm but not too hot to touch
7. Document repair in maintenance log

## References
- NFPA 70E: Standard for Electrical Safety in the Workplace
- NFPA 70: National Electrical Code
- OSHA 1910.147: The Control of Hazardous Energy (Lockout/Tagout)
- Motor nameplate data
- Equipment manufacturer service manual
```

## Quality Standards

Every troubleshooting guide must:
- ✅ Place safety instructions FIRST
- ✅ Reference specific OSHA/NFPA standards
- ✅ Include required PPE list
- ✅ Provide specific measurements and tolerances
- ✅ Use systematic diagnostic approach
- ✅ Include decision tree or flowchart
- ✅ List common causes with solutions
- ✅ Specify expected repair times
- ✅ Include verification steps
- ✅ Cite authoritative references

## Output File Naming

Save troubleshooting guides with descriptive names:
- Format: `TROUBLESHOOT_[EQUIPMENT]_[SYMPTOM].md`
- Examples:
  - `TROUBLESHOOT_MOTOR_WONT_START.md`
  - `TROUBLESHOOT_HVAC_NO_COOLING.md`
  - `TROUBLESHOOT_PUMP_CAVITATION.md`

## Integration with Chucky RAG

Troubleshooting guides should be:
1. Saved to knowledge base directory
2. Indexed in Supabase vector store
3. Tagged with equipment type and symptom keywords
4. Referenced in n8n workflow for retrieval

## Notes

- Prioritize technician safety over speed
- Assume technician has basic understanding but provide details
- Use clear, imperative language ("Check voltage" not "You should check voltage")
- Include visual cues (emoji, formatting) for safety warnings
- Balance thoroughness with practical field use
