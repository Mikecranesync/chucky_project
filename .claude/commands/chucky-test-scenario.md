# Chucky Test Scenario Generator

Generate comprehensive test scenarios for Discord interactions and workflow validation.

## Task

You are the `/chucky-test-scenario` command. Your job is to create detailed, executable test scenarios that verify the Chucky workflow behaves correctly under various conditions.

## Context Files to Read

Read these to understand what to test:
- `context/project_overview.md` - System capabilities and expected behavior
- `context/workflow_architecture.md` - Technical components to test
- `context/discord_config.md` - Discord integration points

## Sub-Agent to Use

Invoke the **testing-coordinator** sub-agent to create comprehensive test plans and validation scripts.

## Input Formats

### 1. Feature-Based Testing
```
/chucky-test-scenario "Test image analysis confidence threshold with blurry equipment photo"
```

### 2. Integration Testing
```
/chucky-test-scenario --integration discord gemini
```

### 3. Error Handling Testing
```
/chucky-test-scenario --error-case "API timeout during RAG retrieval"
```

### 4. End-to-End Testing
```
/chucky-test-scenario --e2e "Complete troubleshooting flow from Discord message to response"
```

## Test Scenario Structure

Every test scenario must follow this comprehensive format:

```markdown
# Test Scenario: [Feature/Behavior Being Tested]

## Test ID
TEST-[CATEGORY]-[NUMBER] (e.g., TEST-IMG-CONF-001)

## Category
[Unit | Integration | E2E | Performance | Security | Error Handling]

## Priority
[Critical | High | Medium | Low]

## Objective
[Clear statement of what this test verifies]

## Prerequisites
- [ ] [System state requirement 1]
- [ ] [Configuration requirement 2]
- [ ] [Data requirement 3]

## Test Data
**Input Files**: [List files in test_assets/ directory]
**Expected Values**: [Specific data points to check]
**Test Account**: [Discord user or test credentials]

## Test Steps
1. [Action to perform]
2. [Next action]
3. [Wait/observe step]
4. [Verification action]

## Expected Result
✅ [Specific expected behavior]

[Detailed description or example output]

## Validation Criteria
- ✅ [Criterion 1 with measurable outcome]
- ✅ [Criterion 2 with measurable outcome]
- ✅ [Criterion 3 with measurable outcome]

## Failure Modes
❌ **If [condition]** → [What it means and what to check]
❌ **If [condition]** → [Diagnosis and fix]

## Pass/Fail Criteria
**PASS**: All validation criteria met
**FAIL**: Any validation criterion not met or failure mode occurs

## Cleanup
[Steps to reset system state after test]

## Related Tests
- [Link to similar or dependent test scenarios]

## Notes
[Any additional context or edge cases]
```

## Test Categories

### 1. Unit Tests
Test individual nodes or components:
- Code node logic
- Conditional branching (IF/Switch nodes)
- Data transformation
- Single API calls

### 2. Integration Tests
Test interactions between components:
- Discord → n8n trigger
- Gemini Vision → Parser
- RAG retrieval → AI Agent
- Agent → Discord output

### 3. End-to-End Tests
Test complete user workflows:
- User sends message → Receives troubleshooting response
- Image analysis → Confidence check → RAG → Response
- Error occurs → User sees friendly error message

### 4. Performance Tests
Test speed and scalability:
- Response time under normal load
- Concurrent user handling
- Large image processing
- Vector store query performance

### 5. Security Tests
Test security controls:
- Input validation (SQL injection, XSS)
- Authentication/authorization
- Credential protection
- Rate limiting

### 6. Error Handling Tests
Test failure scenarios:
- API timeouts
- Invalid inputs
- Missing credentials
- Network failures

## Common Test Scenarios for Chucky

### Image Analysis Tests
1. **High-quality equipment photo** (Expected: confidence >85%)
2. **Blurry/low-quality photo** (Expected: confidence <80%, asks for clarification)
3. **No equipment in image** (Expected: confidence <50%, asks for clarification)
4. **Multiple equipment types** (Expected: identifies primary equipment)
5. **Image with text** (Expected: extracts visible text in response)

### RAG Retrieval Tests
1. **Query matches documentation** (Expected: relevant docs retrieved, similarity >0.7)
2. **Query has no matches** (Expected: falls back to web search)
3. **Ambiguous query** (Expected: retrieves multiple relevant sections)
4. **Very specific query** (Expected: pinpoints exact manual section)

### Discord Integration Tests
1. **Message with !command prefix** (Expected: workflow triggers)
2. **Message without prefix** (Expected: workflow does not trigger)
3. **Message with image attachment** (Expected: image downloaded and analyzed)
4. **Message in wrong channel** (Expected: no response or appropriate message)
5. **@mention in response** (Expected: user is notified)

### Conversation Memory Tests
1. **Follow-up question** (Expected: remembers context from previous message)
2. **New session** (Expected: no memory of previous user's questions)
3. **Multiple users simultaneously** (Expected: separate memory per user)

### Error Handling Tests
1. **Gemini API timeout** (Expected: retry then fallback or error message)
2. **Supabase connection failure** (Expected: graceful error, notify user)
3. **Discord rate limit hit** (Expected: queues message or waits)
4. **Invalid credential** (Expected: workflow fails with clear error log)

## Example: Complete Test Scenario

```markdown
# Test Scenario: Image Analysis Confidence Threshold

## Test ID
TEST-IMG-CONF-001

## Category
Integration

## Priority
Critical

## Objective
Verify that Chucky requests clarification when image analysis confidence is below 80%, and provides direct troubleshooting when confidence is ≥80%.

## Prerequisites
- [ ] Chucky workflow is active in n8n
- [ ] Discord bot is online
- [ ] Gemini Vision API is functional with valid credentials
- [ ] Test images are prepared in test_assets/ directory
- [ ] Test Discord account has access to #troubleshooting channel

## Test Data
**Input Files**:
- `test_assets/blurry_motor.jpg` (Expected confidence: 60-75%)
- `test_assets/clear_motor.jpg` (Expected confidence: >85%)

**Test Discord Channel**: #troubleshooting (ID: 1435030564255170640)
**Test User**: Test Technician account

## Test Steps

### Part A: Low Confidence (Blurry Image)
1. Open Discord and navigate to #troubleshooting channel
2. Upload `blurry_motor.jpg`
3. Type message: `!troubleshoot motor making noise`
4. Press Send
5. Wait for Chucky's response (expected: 5-15 seconds)

### Part B: High Confidence (Clear Image)
1. Upload `clear_motor.jpg`
2. Type message: `!troubleshoot motor making noise`
3. Press Send
4. Wait for Chucky's response

## Expected Result

### Part A Expected Output:
✅ Chucky responds with clarification request:

```
**Clarification Needed** <@TestUser>

I analyzed the image but only have 65% confidence. Can you provide more details?

**What I detected:**
- Category: Electric Motor (possibly 3-phase)
- Description: Motor assembly with visible nameplate, but image quality limits detailed analysis

Please specify:
1. Exact equipment model/type (check nameplate)
2. What specific issue you're experiencing (type of noise, when it occurs)
3. Any error codes or warning indicators

Also, if possible, upload a clearer photo focusing on:
- Motor nameplate with specifications
- Any visible damage or abnormalities
- The area where the noise is coming from
```

### Part B Expected Output:
✅ Chucky responds with troubleshooting steps (no clarification request):

```
**Troubleshooting: Motor Noise** <@TestUser>

Based on the image analysis (Confidence: 92%), here's how to diagnose the noise:

1. **Safety First**
   ⚠️ Apply Lockout/Tagout before inspection

2. **Identify Noise Type**
   - Grinding → Likely bearing failure
   - Humming → Possible electrical issue
   - Rattling → Loose mounting or coupling

[Additional troubleshooting steps...]
```

## Validation Criteria

### Part A (Low Confidence):
- ✅ Response received within 15 seconds
- ✅ Confidence score mentioned in response
- ✅ Confidence value is <80%
- ✅ Message includes "Clarification Needed" or similar phrase
- ✅ User is mentioned with @username
- ✅ Message asks for specific additional information
- ✅ No troubleshooting steps provided (waits for clarification)
- ✅ Suggestions for better image capture included

### Part B (High Confidence):
- ✅ Response received within 15 seconds
- ✅ Confidence score is ≥80%
- ✅ Troubleshooting steps are provided immediately
- ✅ Steps are numbered and formatted clearly
- ✅ Safety warnings are included upfront
- ✅ User is mentioned with @username
- ✅ Response is relevant to "motor making noise"

## Failure Modes

❌ **If no response after 30 seconds** (Part A or B)
→ Check Discord Trigger node is activated
→ Verify network connectivity
→ Check n8n execution logs for errors

❌ **If Part A provides troubleshooting instead of clarification**
→ Gemini Vision is over-confident despite blurry image
→ Adjust confidence threshold in IF node
→ Review image quality in test_assets

❌ **If Part B asks for clarification despite clear image**
→ Gemini Vision is under-confident
→ Check Gemini API response in execution logs
→ Verify correct model is being used (gemini-1.5-pro-latest)

❌ **If error message appears**
→ Check Gemini API quota and credentials
→ Verify image file format is supported (JPEG, PNG)
→ Check image file size (<10MB)

❌ **If confidence score is not mentioned**
→ Parse Vision Response code node may have error
→ Check execution logs for parsing failures
→ Verify JSON structure from Gemini matches parser expectations

## Pass/Fail Criteria

**PASS**: All validation criteria for both Part A and Part B are met
**FAIL**: Any validation criterion not met, or any failure mode occurs

## Cleanup
1. Delete test messages from #troubleshooting channel (optional, can keep for audit)
2. No database cleanup needed (chat memory is per-user and acceptable to keep)
3. Test images remain in test_assets/ for future test runs

## Related Tests
- **TEST-IMG-CONF-002**: Test with high-quality image only (expected: confidence >85%)
- **TEST-IMG-CONF-003**: Test with non-equipment image (expected: confidence <50%)
- **TEST-IMG-CONF-004**: Test confidence threshold edge case (exactly 80%)

## Automation Potential
This test can be automated using:
- Discord API to programmatically send messages
- n8n webhook to capture response
- Assertion library to validate response structure
- CI/CD integration for continuous testing

## Notes
- Confidence scores may vary ±5% depending on Gemini API version
- Test should be run after any changes to Gemini Vision node or parsing logic
- Keep test images consistent to ensure repeatable results
- If Gemini API is updated, re-baseline expected confidence scores
```

## Test Data Management

### Test Asset Organization
```
test_assets/
├── images/
│   ├── clear/
│   │   ├── motor_clear_001.jpg
│   │   ├── pump_clear_001.jpg
│   │   └── hvac_clear_001.jpg
│   ├── blurry/
│   │   ├── motor_blurry_001.jpg
│   │   └── pump_blurry_001.jpg
│   └── invalid/
│       ├── no_equipment.jpg
│       └── random_photo.jpg
├── expected_outputs/
│   ├── clarification_request.txt
│   └── troubleshooting_response.txt
└── test_data.json (metadata about each test file)
```

### Test Data JSON
```json
{
  "test_assets": [
    {
      "file": "images/clear/motor_clear_001.jpg",
      "description": "Clear 3-phase motor photo with visible nameplate",
      "expected_confidence": 90,
      "equipment_type": "motor",
      "test_scenarios": ["TEST-IMG-CONF-002", "TEST-E2E-001"]
    }
  ]
}
```

## Regression Testing

When creating test scenarios, tag them for regression testing:
- **Smoke Tests**: Critical path tests that must pass (5-10 tests)
- **Regression Suite**: All tests to run before deployment (20-50 tests)
- **Extended Suite**: Comprehensive testing including edge cases (100+ tests)

## Test Reporting

After running tests, generate a report:
```markdown
# Test Run Report

**Date**: 2025-11-04
**Workflow Version**: 1.1
**Tester**: Claude Code
**Environment**: Local n8n (localhost:5679)

## Summary
- ✅ Passed: 18
- ❌ Failed: 2
- ⏭️ Skipped: 1
- Total: 21

## Failed Tests
1. **TEST-IMG-CONF-003** - Non-equipment image handling
   - Expected: Confidence <50%
   - Actual: Confidence 62%
   - Action: Retrain Gemini prompt or adjust threshold

2. **TEST-RAG-002** - No matching documents
   - Expected: Falls back to web search
   - Actual: Returns empty response
   - Action: Fix External Search Tool configuration

## Recommendations
1. Adjust confidence threshold from 80% to 75%
2. Add more error handling in RAG retrieval node
3. Improve Gemini prompt for non-equipment detection

## Next Test Run
Scheduled for: 2025-11-05 after fixes applied
```

## Best Practices

1. **Isolation**: Each test should be independent (no dependencies on other tests)
2. **Repeatability**: Same input should always produce same output
3. **Clear Expectations**: Define exact expected behavior, not vague goals
4. **Fast Feedback**: Tests should run quickly (<2 min per test ideal)
5. **Meaningful Names**: Test names should describe what they verify
6. **Documentation**: Every test should be self-documenting

## Integration with CI/CD

Tests can be integrated into automated pipelines:
```bash
# Run smoke tests before deployment
npm run test:smoke

# Run full regression suite
npm run test:regression

# Generate test report
npm run test:report
```

## Notes

- Focus on testing behavior, not implementation
- Test both success and failure paths
- Include boundary conditions and edge cases
- Keep test data separate from production data
- Update tests when workflow changes
