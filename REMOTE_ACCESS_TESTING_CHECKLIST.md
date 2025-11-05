# Remote Access Testing Checklist

**Version:** 1.0.0
**Date:** 2025-11-04

## Pre-Deployment Tests

### VPS Deployment
- [ ] SSH access to VPS works
- [ ] Claude CLI installed (`claude --version`)
- [ ] API keys configured (`echo $ANTHROPIC_API_KEY`)
- [ ] `.claude/` directory present with all agents
- [ ] `context/` files copied
- [ ] `/chucky` command responds
- [ ] Simple test: `claude /chucky "test"`

### Telegram Bot Setup
- [ ] Bot created with @BotFather
- [ ] Bot token saved securely
- [ ] User ID obtained from @userinfobot
- [ ] Workflow imported into n8n
- [ ] Telegram credentials configured
- [ ] SSH credentials configured
- [ ] User whitelist updated with your ID
- [ ] Workflow activated
- [ ] Webhook registered

### Supabase (Optional)
- [ ] Audit table created
- [ ] Supabase credentials in n8n
- [ ] Test insert works

## Functional Tests

### Basic Telegram Commands
1. [ ] Bot responds to messages
   - Send: `/start`
   - Expected: Welcome message

2. [ ] Simple /chucky command
   - Send: `/chucky What can you do?`
   - Expected: Manager capabilities listed
   - Time: < 30 seconds

3. [ ] Node creation
   - Send: `/chucky create a webhook node`
   - Expected: Complete node JSON
   - Time: < 30 seconds

4. [ ] Workflow validation
   - Send: `/chucky validate ChuckyDiscordRAG.json`
   - Expected: Validation report
   - Time: < 45 seconds

### Security Tests
5. [ ] Unauthorized user blocked
   - Test with different Telegram account
   - Expected: "Unauthorized user" error

6. [ ] Command sanitization
   - Send: `/chucky test; rm -rf /`
   - Expected: Unsafe characters blocked

7. [ ] Rate limiting
   - Send 12 commands rapidly
   - Expected: Rate limit error after 10

### Session Memory Tests
8. [ ] Create and modify
   - Send: `/chucky create a sensor node`
   - Then: `/chucky add error handling to it`
   - Expected: "it" references sensor node

9. [ ] Follow-up commands
   - Send: `/chucky create a Discord embed`
   - Then: `/chucky make it orange`
   - Expected: Color changed on same embed

### Template Tests
10. [ ] Production-ready template
    - Send: `/chucky production-ready ChuckyDiscordRAG.json`
    - Expected: Multi-step validation pipeline
    - Time: 5-8 minutes

### Error Handling Tests
11. [ ] Invalid command
    - Send: `/chucky invalid nonsense command`
    - Expected: Graceful error message

12. [ ] SSH failure
    - Temporarily break SSH credentials
    - Send: `/chucky test`
    - Expected: SSH error message (not crash)

13. [ ] Network timeout
    - Send very complex request
    - Expected: Timeout handled gracefully

## Performance Tests

14. [ ] Response time - Simple
    - Command: `/chucky create a Code node`
    - Target: < 30 seconds
    - Actual: ___ seconds

15. [ ] Response time - Complex
    - Command: `/chucky production-ready workflow.json`
    - Target: < 8 minutes
    - Actual: ___ minutes

16. [ ] Concurrent users (if applicable)
    - Multiple users send commands simultaneously
    - Expected: All processed correctly

## Integration Tests

17. [ ] Audit logging
    - Send command
    - Check Supabase `chucky_audit` table
    - Expected: Row inserted with correct data

18. [ ] Error logging
    - Send invalid command
    - Check audit table
    - Expected: Failure logged with error message

## Mobile Tests

19. [ ] iOS Telegram app
    - [ ] Commands work
    - [ ] Responses display correctly
    - [ ] Markdown formatting works

20. [ ] Android Telegram app
    - [ ] Commands work
    - [ ] Responses display correctly
    - [ ] Markdown formatting works

## Edge Cases

21. [ ] Empty command
    - Send: `/chucky`
    - Expected: Help message

22. [ ] Very long command
    - Send: `/chucky [500+ character command]`
    - Expected: Processed or truncated gracefully

23. [ ] Special characters
    - Send: `/chucky test "quotes" and 'apostrophes'`
    - Expected: Handled correctly

24. [ ] Unicode/emoji
    - Send: `/chucky create node with 🚀 emoji`
    - Expected: Processed correctly

## Post-Deployment Monitoring

### Week 1
- [ ] Check audit logs daily
- [ ] Monitor error rates
- [ ] Review execution times
- [ ] Check VPS resources (CPU, RAM, disk)

### Week 2-4
- [ ] Weekly audit log review
- [ ] Identify common usage patterns
- [ ] Optimize slow commands
- [ ] Address recurring errors

## Success Criteria

✅ **Ready for Production When:**
- [ ] All basic tests pass (1-4)
- [ ] Security tests pass (5-7)
- [ ] Session memory works (8-9)
- [ ] Error handling graceful (11-13)
- [ ] Performance acceptable (14-15)
- [ ] Audit logging works (17-18)
- [ ] Mobile apps work (19-20)
- [ ] No critical bugs found

## Known Issues

Document any issues found during testing:

1. Issue: ___
   - Severity: (Critical/High/Medium/Low)
   - Workaround: ___
   - Status: ___

---

**Testing Completed:** ___
**Tested By:** ___
**Production Ready:** Yes / No
**Notes:** ___
