# New Expressions

Test!

| Type | Expression | Definition | Notes
|-|-|-|-
| Death Knight | `change_presence` | Enabled: Can recommend changing to a different presence when a presence is up.<br/>Disabled: Will not recommend changing presence (respects your presence choice).<br/>Default: Disabled. | By default, the addon trusts that you want to be in your current presence, if you have a current presence.
| Action Argument | `precombat_seconds` | If a pull timer has been activated, the precombat recommendation will *not* be available until the pull timer has expired.
| Action Argument | `casts` | The action entry cannot be used if the action has been used this number of times.
| Expression | `casts`<br/>`action.X.casts` | The number of times that ability `X` has been used in combat.  This count resets after an encounter ends (boss fights) or the player is out of combat for 10 seconds or more. | If moving from pack to pack, the opener will not retrigger unless you start an encounter or fall out of combat for 10+ seconds.
