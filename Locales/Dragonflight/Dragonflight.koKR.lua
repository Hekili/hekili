local addon, ns = ...
local L = LibStub("AceLocale-3.0"):NewLocale( "Hekili", "koKR" )

if not L then return end

------------------------------------------------------------------------
-- Death Knight
------------------------------------------------------------------------

if UnitClassBase( "player" ) == "DEATHKNIGHT" then

L["[Any]"] = "[모든 전문화]"

L["Blood"] = "혈기"
L["Save |T237517:0|t Blood Shield"] = "|T237517:0|t 피의 보호막 유지"
L["If checked, the default priority (or any priority checking |cFFFFD100save_blood_shield|r expression) will try to avoid letting your |T237517:0|t Blood Shield fall off during lulls in damage."] = "선택하면 기본 우선순위(또는 |cFFFFD100save_blood_shield|r 표현식을 확인하는 모든 우선순위)는 피해가 줄어드는 상태일 때에도 |T237517:0|t 피의 보호막이 사라지지 않도록 합니다."
L["|T237525:0|t Icebound Fortitude Damage Threshold"] = "|T237525:0|t 얼음같은 인내력의 피해 임계치"
L["When set above zero, the default priority can recommend |T237525:0|t Icebound Fortitude if you've taken this percentage of your maximum health in the past 5 seconds.  Icebound Fortitude also requires the Defensives toggle by default."] = "설정값을 0보다 높게 설정하면, 지난 5초 동안 최대 체력의 이 비율을 소모한 경우 기본 우선순위는 |T237525:0|t 얼음같은 인내력을 추천합니다.  얼음같은 인내력은 기본적으로 방어 토글이 필요합니다."
L["|T237529:0|t Rune Tap Damage Threshold"] = "|T237529:0|t 룬 전환의 피해 임계치"
L["When set above zero, the default priority can recommend |T237529:0|t Rune Tap if you've taken this percentage of your maximum health in the past 5 seconds.  Rune Tap also requires the Defensives toggle by default."] = "설정값을 0보다 높게 설정하면, 지난 5초 동안 최대 체력의 이 비율을 소모한 경우 기본 우선순위는 |T237529:0|t 룬 전환을 추천합니다.  룬 전환은 기본적으로 방어 토글이 필요합니다."
L["|T136168:0|t Vampiric Blood Damage Threshold"] = "|T136168:0|t 흡혈의 피해 임계치"
L["When set above zero, the default priority can recommend |T136168:0|t Vampiric Blood if you've taken this percentage of your maximum health in the past 5 seconds.  Vampiric Blood also requires the Defensives toggle by default."] = "설정값을 0보다 높게 설정하면, 지난 5초 동안 최대 체력의 이 비율을 소모한 경우 기본 우선순위는 |T136168:0|t 흡혈을 추천합니다.  흡혈은 기본적으로 방어 토글이 필요합니다."

L["Frost DK"] = "냉기"
L["Frozen Pulse"] = "얼어붙은 파동"
L["Runic Power for |T1029007:0|t Breath of Sindragosa"] = "|T1029007:0|t 신드라고사의 숨결에 필요한 룬 마력"
L["The addon will recommend |T1029007:0|t Breath of Sindragosa only if you have this much Runic Power (or more)."] = "애드온은 이 정도(또는 그 이상)의 룬 마력이 있는 경우에만 |T1029007:0|t 신드라고사의 숨결을 추천합니다."

L["Unholy"] = "부정"
L["[Wound Spender]"] = "고름 상처 소비하기"
L["Death and Decay"] = "죽음과 부패"
L["|T348565:0|t Outbreak Macro"] = "|T348565:0|t 돌발 열병 매크로"
L["Using a macro makes it easier to apply |T348565:0|t Outbreak to other targets without switching targets."] = "매크로를 사용하면 대상을 전환하지 않고도 다른 대상에 |T348565:0|t 돌발 열병을 더 쉽게 적용할 수 있습니다."

end

------------------------------------------------------------------------
-- Demon Hunder
------------------------------------------------------------------------

if UnitClassBase( "player" ) == "DEMONHUNTER" then

L["Havoc"] = "파멸"
L["|cFFFF0000WARNING!|r  Demon Blades cannot be forecasted.\nSee /hekili > Havoc for more information."] = "|cFFFF0000경고!|r  악마 칼날은 예측할 수 없습니다.\n자세한 정보는 /hekili > 파멸 항목을 참조하세요."
L["Recommend Movement"] = "이동 추천"
L["If checked, the addon will recommend |T1247261:0|t Fel Rush / |T1348401:0|t Vengeful Retreat when it is a potential DPS gain.\n\nThese abilities are critical for DPS when using |T1029722:0|t Momentum and similar talents.\n\nIf not using any talents related to movement, you may want to disable this to avoid unnecessary movement in combat."] = "선택하면 애드온이 잠재적으로 DPS 획득을 할 수 있는 |T1247261:0|t 지옥 돌진 / |T1348401:0|t 복수의 퇴각을 추천합니다.\n\n이러한 능력은 |T1029722:0|t 탄력과 비슷한 특성을 사용할 때 DPS에 매우 중요합니다.\n\n이동과 관련된 특성을 사용하지 않는 경우, 전투에서 불필요한 이동을 피하기 위해 이 기능을 비활성화할 수 있습니다."
L["Recommend Movement for |T1392567:0|t Unbound Chaos"] = "|T1392567:0|t 풀려난 혼돈 이동 추천"
L["When Recommend Movement is disabled, you can enable this option to override it and allow |T1247261:0|t Fel Rush to be recommended when |T1392567:0|t Unbound Chaos is active."] = "이동 추천이 비활성화된 경우, 이 옵션을 활성화하여 |T1392567:0|t 풀려난 혼돈이 활성화되었을 때 |T1247261:0|t 지옥 돌진이 추천되도록 재정의할 수 있습니다."
L["Demon Blades"] = "악마 칼날"
L["|cFFFF0000WARNING!|r  If using the |T237507:0|t Demon Blades talent, the addon will not be able to predict Fury gains from your auto-attacks.  This will result in recommendations that jump forward in your display(s)."] = "|cFFFF0000경고!|r  |T237507:0|t 악마 칼날 특성을 사용하는 경우, 애드온은 자동 공격으로 얻는 분노를 예측할 수 없습니다.  이에 따라 디스플레이에 추천이 앞으로 건너뛰어서 표시됩니다."
L["I understand that Demon Blades is unpredictable; don't warn me."] = "악마 칼날은 예측할 수 없다는 것을 이해했으니 나에게 경고하지 마십시오."
L["If checked, the addon will not provide a warning about Demon Blades when entering combat."] = "선택하면 애드온이 전투에 들어갈 때 악마 칼날에 대해 경고하지 않습니다."

L["Vengeance"] = "복수"
L["Reserve |T1344650:0|t Infernal Strike Charges"] = "|T1344650:0|t 불지옥 일격 충전 비축하기"
L["If set above zero, the addon will not recommend |T1344650:0|t Infernal Strike if it would leave you with fewer charges."] = "설정값을 0보다 높게 설정하면, 애드온은 충전량이 적을 경우 |T1344650:0|t 불지옥 일격을 추천하지 않습니다."
L["Require |T1097742:0|t Frailty Stacks"] = "|T1097742:0|t 약화에 요구되는 중첩"
L["If set above zero, the default priority will not allow certain abilities to be used unless you have at least this many stacks of |T1097742:0|t Frailty on your target.\n\nThis is an experimental setting.  Requiring too many stacks may result in delays to using your major cooldowns and cause a loss of DPS."] = "설정값을 0보다 높게 설정하면, 기본 우선순위는 대상에게 |T1097742:0|t 약화의 중첩이 최소한 이만큼 쌓이지 않으면 특정 능력을 사용할 수 없습니다.\n\n이것은 실험적인 설정입니다.  너무 많은 중첩을 요구하면 주요 재사용 대기시간 사용이 지연되고 DPS가 손실되는 결과가 나올 수 있습니다."

end

------------------------------------------------------------------------
-- Druid
------------------------------------------------------------------------

if UnitClassBase( "player" ) == "DRUID" then

L["Incarnation"] = "화신"

L["Balance"] = "조화"
L["Starsurge Empowerment (Lunar)"] = "별빛쇄도 강화 (달)"
L["Starsurge Empowerment (Solar)"] = "별빛쇄도 강화 (태양)"
L["Cancel |T462651:0|t Starlord"] = "|T462651:0|t 별의 군주 취소하기"
L["If checked, the addon will recommend canceling your Starlord buff before starting to build stacks with Starsurge again.\n\nYou will likely want a |cFFFFD100/cancelaura Starlord|r macro to manage this during combat."] = "선택하면 애드온은 별빛쇄도로 중첩을 다시 쌓기 전에 별의 군주 강화 효과를 취소할 것을 추천합니다.\n\n전투 중에 강화 효과 취소를 관리하기 위해 |cFFFFD100/cancelaura 별의 군주|r 매크로가 필요할 것입니다."
L["Delay |T135727:0|t Berserking (Troll only)"] = "|T135727:0|t 광폭화 지연하기 (트롤 전용)"
L["If checked, the default priority will attempt to adjust the timing of |T135727:0|t Berserking to be consistent with simmed |T135939:0|t Power Infusion usage."] = "선택하면 기본 우선순위는 시뮬레이션된 |T135939:0|t 마력 주입 사용과 타이밍이 일치하도록 |T135727:0|t 광폭화의 타이밍을 조정하려고 시도합니다."

L["Feral"] = "야성"
L["(Cat)"] = "(표범)"
-- L["|T136036:0|t Attempt Owlweaving (Experimental)"] = true
-- L["If checked, the addon will swap to Moonkin Form based on the default priority."] = true
-- L["|T136085:0|t Use Regrowth as Filler"] = true
-- L["If checked, the default priority will recommend |T136085:0|t Regrowth when you use the Bloodtalons talent and would otherwise be pooling Energy to retrigger Bloodtalons."] = true
L["|T132152:0|t Rip Duration"] = "|T132152:0|t 도려내기 지속시간"
L["If set above 0, the addon will not recommend |T132152:0|t Rip if your target will die within the timeframe specified."] = "설정값을 0보다 높게 설정하면, 애드온은 지정된 시간 내에 대상이 죽을 경우 |T132152:0|t 도려내기를 추천하지 않습니다."
L["Allow |T132089:0|t Shadowmeld (Night Elf only)"] = "|T132089:0|t 그림자 숨기를 추천하기 (나이트 엘프 전용)"
L["If checked, |T132089:0|t Shadowmeld can be recommended for Night Elves when its conditions are met.  Your stealth-based abilities can be used in Shadowmeld, even if your action bar does not change.  Shadowmeld can only be recommended in boss fights or when you are in a group (to avoid resetting combat)."] = "선택하면 나이트 엘프 종족인 경우 |T132089:0|t 그림자 숨기를 추천합니다.  행동 단축바가 변경되지 않더라도 그림자 숨기 상태에서 은신 기반의 능력을 사용할 수 있습니다.  그림자 숨기는 (전투 초기화를 방지하기 위해) 우두머리 전투나 파티에 속해 있을 때만 추천합니다."

L["Guardian"] = "수호"
L["(Bear)"] = "(곰)"
L["Excess Rage for |T132136:0|t Maul (or |T132131:0|t Raze)"] = "|T132136:0|t 후려갈기기 또는 |T132131:0|t 말살을 위한 과도한 분노"
L["If set above zero, the addon will recommend |T132136:0|t Maul or |T132131:0|t Raze only if you have at least this much excess Rage."] = "설정값을 0보다 높게 설정하면, 애드온은 최소한 이 정도의 과도한 분노가 있는 경우에만 |T132136:0|t 후려갈기기 또는 |T132131:0|t 말살을 추천합니다."
-- L["Use |T132135:0|t Mangle More in Multi-Target"] = "여러 대상일 때 |T132135:0|t 짓이기기를 더 많이 사용하기"
-- L["If checked, the default priority will recommend |T132135:0|t Mangle more often in |cFFFFD100multi-target|r scenarios.\n\nThis will generate roughly 15% more Rage and allow for more mitigation (or |T132136:0|t Maul) than otherwise, funnel slightly more damage into your primary target, but will |T134296:0|t Swipe less often, dealing less damage/threat to your secondary targets."] = "선택하면 기본 우선순위는 |cFFFFD100여러 대상|r에 대한 시나리오에서 |T132135:0|t 짓이기기를 더 자주 추천합니다.\n\n이것은 약 15% 더 많은 분노를 생성하고 그렇지 않은 경우보다 더 많은 피해 완화(또는 |T132135:0|t 짓이기기)를 허용하며, 주요 대상에게 약간 더 많은 피해를 주지만, |T134296:0|t 휘둘러치기의 빈도가 줄어들어 보조 대상에 대한 피해/위협이 줄어듭니다."
L["Required Damage % for |T1378702:0|t Ironfur"] = "|T1378702:0|t 무쇠가죽에 필요한 피해 %"
L["If set above zero, the addon will not recommend |T1378702:0|t Ironfur unless your incoming damage for the past 5 seconds is greater than this percentage of your maximum health.\n\nThis value is halved when playing solo."] = "설정값을 0보다 높게 설정하면, 지난 5초 동안 받은 피해가 최대 체력의 이 비율보다 크지 않으면 애드온이 |T1378702:0|t 무쇠가죽을 추천하지 않습니다.\n\n혼자 플레이를 하면 이 값은 절반으로 줄어들게 됩니다."
-- L["|T3636839:0|t Powershift for Convoke the Spirits"] = true
-- L["If checked, the addon will recommend swapping to Cat Form before using |T3636839:0|t Convoke the Spirits.\n\nThis is a DPS gain unless you die horribly."] = true
L["|T132115:0|t Attempt Catweaving (Experimental)"] = "|T132115:0|t 고양이 위빙을 시도 (실험)"
L["If checked, the addon will use the experimental |cFFFFD100catweave|r priority included in the default priority pack."] = "선택하면 애드온은 기본 우선순위 팩에 포함된 실험적인 |cFFFFD100catweave|r 우선순위를 사용합니다."
L["|T136036:0|t Attempt Owlweaving (Experimental)"] = "|T136036:0|t 올빼미 위빙을 시도 (실험)"
L["If checked, the addon will use the experimental |cFFFFD100owlweave|r priority included in the default priority pack."] = "선택하면 애드온은 기본 우선순위 팩에 포함된 실험적인 |cFFFFD100owlweave|r 우선순위를 사용합니다."

L["Restoration"] = "회복"
L["|cFFFF0000WARNING|r:  Healer support in this addon is focused on DPS output only.  This is more useful for solo content or downtime when your healing output is less critical in a group/encounter.  Use at your own risk."] = "|cFFFF0000경고|r:  이 애드온의 힐러 지원은 DPS 피해량에만 집중되어 있습니다.  이 기능은 솔로 콘텐츠나 그룹/교전에서 치유량이 중요하지 않은 여유로운 시간일 때 더 유용합니다.  본인 책임하에 사용하세요."

end

------------------------------------------------------------------------
-- Evoker
------------------------------------------------------------------------

if UnitClassBase( "player" ) == "EVOKER" then

L["Use |T4622450:0|t Deep Breath"] = "|T4622450:0|t 깊은 숨결 사용하기"
L["If checked, the addon may recommend |T4622450:0|t Deep Breath, which causes your character to fly forward while damaging enemies.  This ability requires your Cooldowns toggle to be active by default.\n\nDisabling this setting will prevent the addon from ever recommending Deep Breath, which you may prefer due to the movement (or for any other reason)."] = "선택하면 애드온이 적에게 피해를 입히면서 캐릭터가 앞으로 날아가게 하는 |T4622450:0|t 깊은 숨결을 추천합니다.  이 기능을 사용하려면 재사용 대기시간 토글이 기본적으로 동작하고 있어야 합니다.\n\n이 설정을 비활성화하면 애드온이 캐릭터의 움직임으로(또는 다른 이유로) 인해 선호할 수 있는 깊은 숨결이 추천되지 않습니다."
L["Use |T4630499:0|t Unravel"] = "|T4630499:0|t 해체 사용하기"
L["If checked, the addon may recommend |T4630499:0|t Unravel when your target has an absorb shield applied.  By default, Unravel also requires your Interrupts toggle to be active."] = "선택하면 대상에 흡수 보호막이 적용된 경우 애드온에서 |T4630499:0|t 해체를 추천합니다.  기본적으로 해체를 사용하려면 차단 토글이 동작하고 있어야 합니다."
L["Early Chain |T4622451:0|t Disintegrate"] = "|T4622451:0|t 파열을 일찍 이어서 사용하기"
L["If checked, the default priority may recommend |T4622451:0|t Disintegrate in the middle of a Disintegrate channel."] = "선택하면 기본 우선순위는 파열 시전을 정신 집중하는 중간에 |T4622451:0|t 파열을 추천합니다."
L["Clip |T4622451:0|t Disintegrate"] = "|T4622451:0|t 파열 시전 자르기"
L["If checked, the default priority may recommend interrupting a |T4622451:0|t Disintegrate channel when another spell is ready."] = "선택하면 기본 우선순위는 다른 주문이 준비되었을 때 |T4622451:0|t 파열 시전의 정신 집중을 차단하도록 추천합니다."

L["Devastation"] = "황폐"

L["Preservation"] = "보존"

end

------------------------------------------------------------------------
-- Hunter
------------------------------------------------------------------------

if UnitClassBase( "player" ) == "HUNTER" then

L["Beast Mastery"] = "야수"
L["|T2058007:0|t Barbed Shot Grace Period"] = "|T2058007:0|t 날카로운 사격 유예 시간"
L["If set above zero, the addon (using the default priority or |cFFFFD100barbed_shot_grace_period|r expression) will recommend |T2058007:0|t Barbed Shot up to 1 global cooldown earlier."] = "설정값을 0보다 높게 설정하면, 애드온은 (기본 우선순위 또는 |cFFFFD100barbed_shot_grace_period|r 표현식을 사용하여) |T2058007:0|t 날카로운 사격을 최대 1의 전역 재사용 대기시간까지 더 일찍 추천합니다."
L["Avoid |T132127:0|t Bestial Wrath Overlap"] = "|T132127:0|t 야수의 격노 중복 방지"
L["If checked, the addon will not recommend |T132127:0|t Bestial Wrath if the buff is already applied."] = "선택하면 이미 강화 효과가 적용된 경우 애드온이 |T132127:0|t 야수의 격노를 추천하지 않습니다."
L["Check Pet Range for |T132176:0|t Kill Command"] = "|T132176:0|t 살상 명령에 대한 소환수 범위 확인"
L["If checked, the addon will not recommend |T132176:0|t Kill Command if your pet is not in range of your target.\n\nRequires |c%sPet-Based Target Detection|r."] = "선택하면 소환수가 대상의 사정거리를 벗어난 경우 애드온이 |T132176:0|t 살상 명령을 추천하지 않습니다.\n\n|c%s소환수 기반의 대상 감지|r가 필요합니다."

L["Marksmanship"] = "사격"
L["Prevent Hardcasts of |T135130:0|t Aimed Shot During Movement"] = "이동하는 중에 |T135130:0|t 조준 사격에 대한 하드캐스트 방지"
L["If checked, the addon will not recommend |T135130:0|t Aimed Shot if it has a cast time and you are moving."] = "선택하면 애드온은 시전 시간이 있고 이동 중인 경우 |T135130:0|t 조준 사격을 추천하지 않습니다.\n\n(하드캐스트는 즉시 시전하는 발동 없이 수동으로 시전하는 것을 의미합니다)"
L["Use |T132329:0|t Trueshot with |T537444:0|t Eagletalon's True Focus Runeforge"] = "|T537444:0|t 독수리발톱의 흔들림 없는 집중과 함께 |T132329:0|t 정조준 사용하기"
L["If checked, the default priority includes usage of |T132329:0|t Trueshot pre-pull, assuming you will successfully swap your legendary on your own.  The addon will not tell you to swap your gear."] = "선택하면 기본 우선순위에 |T132329:0|t 정조준을 사전 풀링할 때 |T537444:0|t 독수리발톱의 흔들림 없는 집중을 사용하는 것을 포함하며, 플레이어가 전투를 시작하기 전에 전설 장비를 성공적으로 교체할 것이라고 가정합니다.  하지만 애드온은 장비를 교체하라는 메시지를 표시하지 않습니다."

L["Survival"] = "생존"
L["Use |T1376040:0|t Harpoon"] = "|T1376040:0|t 작살 사용하기"
L["If checked, the addon will recommend |T1376040:0|t Harpoon when you are out of range and Harpoon is available."] = "선택하면 사정거리를 벗어나고 |T1376040:0|t 작살을 사용할 수 있을 때 애드온이 작살을 추천합니다."
L["Allow Focus Overcap"] = "집중 초과 허용"
L["The default priority tries to avoid overcapping Focus by default.  In simulations, this helps to avoid wasting Focus.  In actual gameplay, this can result in trying to use Focus spenders when other important buttons (Wildfire Bomb, Kill Command) are available to push.  On average, enabling this feature appears to be DPS neutral vs. the default setting, but has higher variance.  Your mileage may vary.\n\nThe default setting is |cFFFFD100unchecked|r."] = "기본 우선순위는 기본적으로 집중의 초과하지 않도록 방지합니다.  시뮬레이션의 결과를 보면, 이 기능은 집중의 낭비를 방지하는 데 도움이 됩니다.  실제 게임 플레이에서 이로 인해 다른 중요한 버튼(야생불 폭탄, 살상 명령)을 누를 수 있을 때 집중 소비하기를 시도하려고 할 수 있습니다.  평균적으로 이 기능을 활성화하면 기본 설정에 비해 DPS 중립적인 것처럼 보이지만, 편차가 더 커집니다.  여러분의 생각이나 경험은 다를 수 있습니다.\n\n기본 설정은 |cFFFFD100선택 안 함|r입니다."  

end

------------------------------------------------------------------------
-- Mage
------------------------------------------------------------------------

if UnitClassBase( "player" ) == "MAGE" then

L["Arcane"] = "비전"
L["Mana Gem"] = "마나석"

L["Fire"] = "화염"
-- L["Accept Fire Disclaimer"] = true
-- L["The Fire Mage module is disabled by default, as it tends to require *much* more CPU usage than any other specialization module.  If you wish to use the Fire module, can check this box and reload your UI (|cFFFFD100/reload|r) and the module will be available again."] = true
L["Allow |T135808:0|t Pyroblast Hardcast Pre-Pull"] = "|T135808:0|t 불덩이 작렬을 하드캐스트로 사전 풀링하기"
L["If checked, the addon will recommend an opener |T135808:0|t Pyroblast against bosses, if included in the current priority."] = "선택하면 애드온은 현재 우선순위에 포함된 경우 우두머리에 대한 오프너로 |T135808:0|t 불덩이 작렬을 추천합니다.\n\n(하드캐스트는 즉시 시전하는 발동 없이 수동으로 시전하는 것을 의미합니다)"
L["Prevent |T135808:0|t Pyroblast and |T135812:0|t Fireball Hardcasts While Moving"] = "이동하는 중에 |T135808:0|t 불덩이 작렬 및 |T135812:0|t 화염구를 하드캐스트하는 것을 방지"
L["If checked, the addon will not recommend |T135808:0|t Pyroblast or |T135812:0|t Fireball if they have a cast time and you are moving.\n\nInstant |T135808:0|t Pyroblasts will not be affected."] = "선택하면 애드온은 시전 시간이 있고 플레이어가 움직이고 있는 경우 |T135808:0|t 불덩이 작렬 또는 |T135812:0|t 화염구를 추천하지 않습니다.\n\n즉시 시전되는 불덩이 작렬은 영향을 받지 않습니다.\n\n(하드캐스트는 즉시 시전하는 발동 없이 수동으로 시전하는 것을 의미합니다)"

L["Frost Mage"] = "냉기"
-- L["Ignore |T629077:0|t Freezing Rain in Single-Target"] = true
-- L["If checked, the default action list will not recommend using |T135857:0|t Blizzard in single-target due to the |T629077:0|t Freezing Rain talent proc."] = true
L["Manually Control |T1698701:0|t Water Jet (Water Elemental)"] = "|T1698701:0|t 물 분출을 수동으로 제어 (물의 정령)"
L["If checked, |T1698701:0|t Water Jet can be recommended by the addon.  This spell is normally auto-cast by your Water Elemental.  You will want to disable its auto-cast before using this feature."] = "선택하면 애드온에서 |T1698701:0|t 물 분출을 추천합니다.  이 주문은 일반적으로 물의 정령에 의해 자동 시전됩니다.  이 기능을 사용하기 전에 자동 시전을 비활성화하는 것이 좋습니다."

end

------------------------------------------------------------------------
-- Monk
------------------------------------------------------------------------

if UnitClassBase( "player" ) == "MONK" then

L["Brewmaster"] = "양조"
L["Use |T606543:0|t Spinning Crane Kick in Single-Target with |T611419:0|t Walk with the Ox"] = "|T611419:0|t 황소와 함께 걷기를 사용하고 단일 대상에게 |T606543:0|t 회전 학다리차기 사용"
L["If checked, the default priority will recommend |T606543:0|t Spinning Crane Kick when |T611419:0|t Walk with the Ox is active.  This tends to reduce mitigation slightly but increase damage based on using |T627607:0|t Invoke Niuzao more frequently."] = "선택하면 기본 우선순위는 |T611419:0|t 황소와 함께 걷기가 활성화된 경우 |T606543:0|t 회전 학다리차기를 추천합니다.  피해 완화가 약간 감소하는 경향이 있지만 |T627607:0|t 니우짜오 부르기를 더 자주 사용하면 피해가 증가하게 됩니다."
L["Maximize |T1360979:0|t Celestial Brew Shield"] = "|T1360979:0|t 천신주 보호막 최대화"
L["If checked, the addon will focus on using |T133701:0|t Purifying Brew as often as possible, to build stacks of Purified Chi for your Celestial Brew shield.\n\nThis is likely to work best with the Light Brewing talent, but risks leaving you without a charge of Purifying Brew following a large spike in your Stagger.\n\nCustom priorities may ignore this setting."] = "선택하면 애드온은 |T133701:0|t 정화주를 최대한 자주 사용하여 천신주 보호막에 정화된 기를 쌓도록 합니다.\n\n간편 양조 특성과 가장 잘 맞을 가능성이 높지만, 시간차가 크게 증가한 이후에 정화주를 충전하지 않고 떠나버릴 위험이 있습니다.\n\n사용자 정의 우선순위는 이 설정을 무시할 수 있습니다."
L["|T133701:0|t Purifying Brew: Stagger Tick % Current Health"] = "|T133701:0|t 정화주: 시간차의 틱에 필요한 현재 체력 %"
L["If set above zero, the addon will recommend |T133701:0|t Purifying Brew when your current stagger ticks for this percentage of your |cFFFF0000current|r effective health (or more).  Custom priorities may ignore this setting.\n\nThis value is halved when playing solo."] = "설정값을 0보다 높게 설정하면, |cFFFF0000현재|r 유효 체력의 이 비율(또는 그 이상)에 대해 현재 시간차가 틱을 할 때 애드온이 |T133701:0|t 정화주를 추천합니다.  사용자 정의 우선순위는 이 설정을 무시할 수 있습니다.\n\n혼자 플레이를 하면 이 값은 절반으로 줄어들게 됩니다."
L["|T133701:0|t Purifying Brew: Stagger Tick % Maximum Health"] = "|T133701:0|t 정화주: 시간차의 틱에 필요한 최대 체력 %"
L["If set above zero, the addon will recommend |T133701:0|t Purifying Brew when your current stagger ticks for this percentage of your |cFFFF0000maximum|r health (or more).  Custom priorities may ignore this setting.\n\nThis value is halved when playing solo."] = "설정값을 0보다 높게 설정하면, |cFFFF0000최대|r 체력의 이 비율(또는 그 이상)에 대해 현재 시간차가 틱을 할 때 애드온이 |T133701:0|t 정화주를 추천합니다.  사용자 정의 우선순위는 이 설정을 무시할 수 있습니다.\n\n혼자 플레이를 하면 이 값은 절반으로 줄어들게 됩니다."
L["|T615339:0|t Breath of Fire: Require |T594274:0|t Keg Smash %"] = "|T615339:0|t 불의 숨결: |T594274:0|t 맥주통 휘두르기에 필요한 %"
L["If set above zero, |T615339:0|t Breath of Fire will only be recommended if this percentage of your targets are afflicted with |T594274:0|t Keg Smash.\n\nExample:  If set to |cFFFFD10050|r, with 2 targets, Breath of Fire will be saved until at least 1 target has Keg Smash applied."] = "설정값을 0보다 높게 설정하면, |T615339:0|t 불의 숨결은 대상이 |T594274:0|t 맥주통 휘두르기에 이 비율의 피해를 입은 경우에만 추천합니다.\n\n예: 만약에 |cFFFFD10050|r으로 설정하고 2개의 대상인 경우, 적어도 1개의 대상이 맥주통 휘두르기에 적용될 때까지 불의 숨결은 저장됩니다."
L["|T627486:0|t Expel Harm: Health %"] = "|T627486:0|t 해악 축출: 체력 %"
L["If set above zero, the addon will not recommend |T627486:0|t Expel Harm until your health falls below this percentage."] = "설정값을 0보다 높게 설정하면, 체력이 이 비율 아래로 떨어질 때까지 애드온은 |T627486:0|t 해악 축출을 추천하지 않습니다."

L["Mistweaver"] = "운무"

L["Windwalker"] = "풍운"
L["Flying Serpent Kick"] = "비룡차기"
L["Use |T606545:0|t Flying Serpent Kick"] = "|T606545:0|t 비룡차기 사용"
L["If unchecked, |T606545:0|t Flying Serpent Kick will not be recommended (this is the same as disabling the ability via Windwalker > Abilities > Flying Serpent Kick > Disable)."] = "선택하지 않으면 |T606545:0|t 비룡차기가 추천되지 않습니다 (풍운 > 능력 > 비룡차기 > 비활성화 항목을 통해 능력을 비활성화하는 것과 같습니다)."
-- L["Optimize |T627486:0|t Reverse Harm"] = true
-- L["If checked, |T627486:0|t Reverse Harm's caption will show the recommended target's name."] = true
L["Reserve One |T136038:0|t Storm, Earth, and Fire Charge as CD"] = "|T136038:0|t 폭풍과 대지와 불 충전을 재사용 대기시간으로 1개 비축하기"
L["If checked, |T136038:0|t when Storm, Earth, and Fire's toggle is set to Default, only one charge will be reserved for use with the Cooldowns toggle."] = "선택하면 |T136038:0|t 폭풍과 대지와 불의 토글이 기본값으로 설정되어 있을 때, 재사용 대기시간 토글과 함께 사용하기 위해 1개의 충전만 비축합니다."
L["Required Damage for |T651728:0|t Touch of Karma"] = "|T651728:0|t 업보의 손아귀에 필요한 피해 %"
L["If set above zero, |T651728:0|t Touch of Karma will only be recommended while you have taken this percentage of your maximum health in damage in the past 3 seconds."] = "설정값을 0보다 높게 설정하면, |T651728:0|t 업보의 손아귀는 지난 3초 동안 최대 체력의 이 비율에 해당하는 피해를 입었을 때만 추천됩니다."
L["Check |T988194:0|t Whirling Dragon Punch Range"] = "|T988194:0|t 소용돌이 용의 주먹의 범위 확인"
L["If checked, when your target is outside of |T988194:0|t Whirling Dragon Punch's range, it will not be recommended."] = "선택하면 대상이 |T988194:0|t 소용돌이 용의 주먹의 사정거리를 벗어난 경우 추천하지 않습니다."
L["Check |T606543:0|t Spinning Crane Kick Range"] = "|T606543:0|t 회전 학다리차기의 범위 확인"
L["If checked, when your target is outside of |T606543:0|t Spinning Crane Kick's range, it will not be recommended."] = "선택하면 대상이 |T606543:0|t 회전 학다리차기의 사정거리를 벗어난 경우 추천하지 않습니다."
L["Use |T775460:0|t Diffuse Magic to Self-Dispel"] = "|T775460:0|t 마법 해소를 사용하여 자신에게 무효화"
L["If checked, when you have a dispellable magic debuff, |T775460:0|t Diffuse Magic can be recommended in the default Windwalker priority.\n\nRequires %s|r Toggle."] = "선택하면 해제 가능한 마법 약화 효과가 있을 때, 기본 풍운 우선순위에서 |T775460:0|t 마법 해소를 추천합니다.\n\n%s|r 토글이 필요합니다."
L["If checked, when you have a dispellable magic debuff, |T775460:0|t Diffuse Magic can be recommended in the default Windwalker priority."] = "선택하면 해제 가능한 마법 약화 효과가 있을 때, 기본 풍운 우선순위에서 |T775460:0|t 마법 해소를 추천합니다."

end

------------------------------------------------------------------------
-- Paladin
------------------------------------------------------------------------

if UnitClassBase( "player" ) == "PALADIN" then

L["Holy"] = "신성"

L["Protection Paladin"] = "보호"
L["|T133192:0|t Word of Glory Health Threshold"] = "|T133192:0|t 영광의 서약 체력 임계치"
L["When set above zero, the addon may recommend |T133192:0|t Word of Glory when your health falls below this percentage."] = "설정값을 0보다 높게 설정하면, 체력이 이 비율 아래로 떨어질 때 애드온이 |T133192:0|t 영광의 서약을 추천합니다."
L["|T135919:0|t Guardian of Ancient Kings Damage Threshold"] = "|T135919:0|t 고대 왕의 수호자 피해 임계치"
L["Guardian of Ancient Kings"] = "고대 왕의 수호자"
L["|T524354:0|t Divine Shield Damage Threshold"] = "|T524354:0|t 천상의 보호막 피해 임계치"
L["Divine Shield"] = "천상의 보호막"
L["When set above zero, the addon may recommend %s when you take this percentage of your maximum health in damage in the past 5 seconds.\n\nBy default, your Defensives toggle must also be enabled."] = "설정값을 0보다 높게 설정하면, 애드온은 지난 5초 동안 최대 체력의 이 비율의 피해를 입었을 때 %s|1을;를; 추천합니다.\n\n기본적으로 방어 토글도 활성화해야 합니다."

L["Retribution"] = "징벌"
L["Check |T1112939:0|t Wake of Ashes Range"] = "|T1112939:0|t 파멸의 재 범위 확인"
L["If checked, when your target is outside of |T1112939:0|t Wake of Ashes' range, it will not be recommended."] = "선택하면 대상이 |T1112939:0|t 파멸의 재의 사정거리를 벗어난 경우 추천하지 않습니다."
L["|T236264:0|t Shield of Vengeance Damage Threshold"] = "|T236264:0|t 복수의 방패 피해 임계치"
L["If set above zero, |T236264:0|t Shield of Vengeance can only be recommended when you've taken the specified amount of damage in the last 5 seconds, in addition to any other criteria in the priority."] = "설정값을 0보다 높게 설정하면, |T236264:0|t 복수의 방패는 우선순위의 다른 기준과 더불어 지난 5초 동안 지정된 피해를 받은 경우에만 추천합니다."

end

------------------------------------------------------------------------
-- Priest
------------------------------------------------------------------------

if UnitClassBase( "player" ) == "PRIEST" then

L["Discipline"] = "수양"

L["Holy"] = "신성"

L["Shadow"] = "암흑"
L["Pad |T1035040:0|t Void Bolt Cooldown"] = "|T1035040:0|t 공허의 화살의 재사용 대기시간 채우기"
L["If checked, the addon will treat |T1035040:0|t Void Bolt's cooldown as slightly shorter, to help ensure that it is recommended as frequently as possible during |T1386550:0|t Voidform."] = "선택하면 |T1386550:0|t 공허의 형상의 지속시간 동안 가능한 한 자주 추천되도록, 애드온이 |T1035040:0|t 공허의 화살의 재사용 대기시간을 약간 짧게 처리합니다."
L["Pad |T3528286:0|t Ascended Blast Cooldown"] = "|T3528286:0|t 승천의 작렬의 재사용 대기시간 채우기"
L["If checked, the addon will treat |T3528286:0|t Ascended Blast's cooldown as slightly shorter, to help ensure that it is recommended as frequently as possible during |T3565449:0|t Boon of the Ascended."] = "선택하면 |T3565449:0|t 승천자의 은혜의 지속시간 동안 가능한 한 자주 추천되도록, 애드온이 |T3528286:0|t 승천의 작렬의 재사용 대기시간을 약간 짧게 처리합니다."
L["|T136149:0|t Shadow Word: Death Health Threshold"] = "|T136149:0|t 어둠의 권능: 죽음 체력 임계치"
L["If set above 0, the addon will not recommend |T136149:0|t Shadow Word: Death while your health percentage is below this threshold.  This setting can help keep you from killing yourself."] = "설정값을 0보다 높게 설정하면, 애드온은 체력 비율이 이 임계치의 미만인 경우 |T136149:0|t 어둠의 권능: 죽음을 추천하지 않습니다.  이 설정은 자살을 방지하는 데 도움이 됩니다."
L["|T237565:0|t Mind Sear Ticks"] = "|T237565:0|t 정신 불태우기의 틱"
L["|T237565:0|t Mind Sear costs 25 Insanity (and 25 additional Insanity per tick).  If set above 0, this setting will treat Mind Sear as unusable if your cast would result in fewer ticks of Mind Sear than desired."] = "|T237565:0|t 정신 불태우기는 25의 광기(그리고 틱당 25의 추가 광기)가 필요합니다.  설정값을 0보다 높게 설정하면, 이 설정은 시전으로 인해 원하는 것보다 적은 수의 정신 불태우기의 틱이 발생하는 경우 정신 불태우기를 사용할 수 없는 것으로 처리합니다."

end

------------------------------------------------------------------------
-- Rogue
------------------------------------------------------------------------

if UnitClassBase( "player" ) == "ROGUE" then

L["|T236364:0|t Marked for Death Combo Points"] = "|T236364:0|t 죽음의 표적 연계 점수"
L["The addon will only recommend |T236364:0|t Marked for Death when you have the specified number of combo points or fewer."] = "애드온은 지정된 연계 점수 이하인 경우에만 |T236364:0|t 죽음의 표적을 추천합니다."
L["Allow |T132089:0|t Shadowmeld (Night Elf only)"] = "|T132089:0|t 그림자 숨기를 추천하기 (나이트 엘프 전용)"
L["If checked, |T132089:0|t Shadowmeld can be recommended for Night Elves when its conditions are met.  Your stealth-based abilities can be used in Shadowmeld, even if your action bar does not change.  Shadowmeld can only be recommended in boss fights or when you are in a group (to avoid resetting combat)."] = "선택하면 나이트 엘프 종족인 경우 |T132089:0|t 그림자 숨기를 추천합니다.  행동 단축바가 변경되지 않더라도 그림자 숨기 상태에서 은신 기반의 능력을 사용할 수 있습니다.  그림자 숨기는 (전투 초기화를 방지하기 위해) 우두머리 전투나 파티에 속해 있을 때만 추천합니다."
L["Allow |T132331:0|t Vanish when Solo"] = "혼자 플레이할 때 |T132331:0|t 소멸 사용"
L["If unchecked, the addon will not recommend |T132331:0|t Vanish when you are alone (to avoid resetting combat)."] = "선택하지 않은 경우, 애드온은 혼자 플레이할 때 (전투 초기화를 방지하기 위해) |T132331:0|t 소멸을 추천하지 않습니다."

L["Assassination"] = "암살"
L["Funnel AOE -> Target"] = "광역 -> 대상으로 집중"
L["If checked, the addon's default priority list will focus on funneling damage into your primary target when multiple enemies are present."] = "선택하면 애드온의 기본 우선순위 목록은 다수의 적이 존재할 때 주요 대상에 피해를 입히는 데 집중합니다."
L["Energy % for |T132287:0|t Envenom"] = "|T132287:0|t 독살에 대한 기력 %"
L["If set above 0, the addon will pool to this Energy threshold before recommending |T132287:0|t Envenom."] = "설정값을 0보다 높게 설정하면, 애드온이 |T132287:0|t 독살을 추천하기 전에 이 기력의 임계치까지 기력을 모읍니다."

L["Outlaw"] = "무법"
L["Use |T132282:0|t Ambush Regardless of Talents"] = "특성에 관계없이 |T132282:0|t 매복 사용하기"
L["If checked, the addon will recommend |T132282:0|t Ambush even without Hidden Opportunity or Find Weakness talented.\n\nDragonflight sim profiles only use Ambush with Hidden Opportunity or Find Weakness talented; this is likely suboptimal."] = "선택하면 애드온은 숨겨진 기회나 약점 포착 특성이 없어도 |T132282:0|t 매복을 추천합니다.\n\n용군단 시뮬레이션 프로필은 숨겨진 기회 또는 약점 포착 특성이 있는 매복만 사용합니다; 이 설정은 차선책입니다."

L["Subtlety"] = "잠행"
L["Use Priority Rotation (Funnel Damage)"] = "우선순위 로테이션 사용 (피해 집중)"
L["If checked, the default priority will recommend building combo points with |T1375677:0|t Shuriken Storm and spending on single-target finishers."] = "선택하면 기본 우선순위는 |T1375677:0|t 표창 폭풍으로 연계 점수를 구축하고 단일 대상에 대한 마무리 일격으로 소비하도록 추천합니다."

end

------------------------------------------------------------------------
-- Shaman
------------------------------------------------------------------------

if UnitClassBase( "player" ) == "SHAMAN" then

L["Use |T136075:0|t Purge or |T451166:0|t Greater Purge on Enemies"] = "적에게 |T136075:0|t 정화 또는 |T451166:0|t 상급 정화 사용하기"
L["If checked, |T136075:0|t Purge or |T451166:0|t Greater Purge can be recommended by the addon when your target has a dispellable magic effect.\n\nThese abilities are also on the Interrupts toggle by default."] = "선택하면 |T136075:0|t 정화 또는 |T451166:0|t 상급 정화는 대상이 해제 가능한 마법 효과를 가지고 있을 때 애드온에서 추천합니다.\n\n이러한 능력은 기본적으로 차단 토글에도 있습니다."
L["|T136075:0|t Purge Internal Cooldown"] = "|T136075:0|t 정화의 내부 재사용 대기시간"
L["If set above zero, the addon will not recommend |T136075:0|t Purge more frequently than this amount of time, even if there are more dispellable magic effects on your target.  This can prevent you from being encouraged to spam Purge endlessly against enemies with rapidly stacking magic buffs."] = "설정값을 0보다 높게 설정하면, 대상에 해제할 수 있는 마법 효과가 더 많더라도 애드온이 이 시간보다 더 자주 |T136075:0|t 정화를 추천하지 않습니다.  이렇게 하면 마법 강화 효과가 빠르게 쌓이는 적에게 끝없이 정화를 스팸하도록 추천되는 것을 방지할 수 있습니다."

L["Elemental"] = "정기"
L["|T135855:0|t Icefury and |T839977:0|t Stormkeeper Padding"] = "|T135855:0|t 얼음격노와 |T839977:0|t 폭풍수호자 채우기"
L["The default priority tries to avoid wasting |T839977:0|t Stormkeeper and |T135855:0|t Icefury stacks with a grace period of 1.1 GCD per stack.\n\nIncreasing this number will reduce the likelihood of wasted Icefury / Stormkeeper stacks due to other procs taking priority, and leave you with more time to react."] = "기본 우선순위는 중첩당 1.1의 전역 재사용 대기시간의 유예 시간으로 |T839977:0|t 폭풍수호자 및 |T135855:0|t 얼음격노의 중첩을 낭비하지 않도록 합니다.\n\n이 설정의 수치를 증가하면 다른 발동이 우선적으로 처리되어 얼음격노/폭풍수호자의 중첩이 낭비될 가능성이 줄어들고 반응할 시간이 더 많이 남게 됩니다."

L["Enhancement"] = "고양"
L["Pad |T1029585:0|t Windstrike Cooldown"] = "|T1029585:0|t 바람의 일격의 재사용 대기시간 채우기"
L["If checked, the addon will treat |T1029585:0|t Windstrike's cooldown as slightly shorter, to help ensure that it is recommended as frequently as possible during |T135791:0|t Ascendance."] = "선택하면 애드온이 |T1029585:0|t 바람의 일격의 재사용 대기시간을 약간 짧게 처리하여 |T135791:0|t 승천의 지속 시간 동안 가능한 한 자주 추천되도록 합니다."
L["Pad |T236289:0|t Lava Lash Cooldown"] = "|T236289:0|t 용암 채찍의 재사용 대기시간 채우기"
L["If checked, the addon will treat |T236289:0|t Lava Lash's cooldown as slightly shorter, to help ensure that it is recommended as frequently as possible during |T135823:0|t Hot Hand."] = "선택하면 애드온이 |T236289:0|t 용암 채찍의 재사용 대기시간을 약간 짧게 처리하여 |T135823:0|t 뜨거운 손의 지속 시간 동안 가능한 한 자주 추천되도록 합니다."
L["Burn Maelstrom before |T3578231:0|t Primordial Wave"] = "|T3578231:0|t 태고의 파도를 사용하기 전에 소용돌이 소모하기"
L["If checked, the default priority will recommend spending your Maelstrom Weapon stacks before using |T3578231:0|t Primordial Wave if you have Primal Maelstrom talented.\n\nIn 10.0.5, this appears to be damage-neutral in single-target and a slight increase in multi-target scenarios."] = "선택하면 기본 우선순위는 원시 소용돌이 특성이 있는 경우 |T3578231:0|t 태고의 파도를 사용하기 전에 소용돌이치는 무기 중첩을 사용하도록 추천합니다.\n\n패치 10.0.5에서 이것은 단일 대상에서 중립 피해인 것으로 나타나고 여러 대상 시나리오에서는 피해가 약간 증가합니다."
L["Filler |T135813:0|t Shock"] = "|T135813:0|t 충격으로 채워넣기"
L["If checked, the addon's default priority will recommend a filler |T135813:0|t Flame Shock when there's nothing else to push, even if something better will be off cooldown very soon.  This matches sim behavior and is a small DPS increase, but has been confusing to some users."] = "선택하면 애드온의 기본 우선순위는 더 나은 능력이 곧 재사용 대기시간이 종료 되더라도, 더 이상 추천으로 밀어낼 능력이 없는 경우 채워넣기 용도로 화염 충격을 추천합니다.  이것은 시뮬레이션 동작과 일치하고 DPS가 약간 증가하지만 일부 사용자에게는 혼란스럽게 느껴지곤 합니다."

L["Restoration"] = "복원"

end

------------------------------------------------------------------------
-- Warlock
------------------------------------------------------------------------

if UnitClassBase( "player" ) == "WARLOCK" then

L["Summon Demon"] = "악마 소환"

L["Affliction"] = "고통"
L["Model |T136163:0|t Drain Soul Ticks"] = "|T136163:0|t 영혼 흡수의 틱에 대한 모델링"
L["If checked, the addon will expend |cFFFF0000more CPU|r determining when to break |T136163:0|t Drain Soul channels in favor of other spells.  This is generally not worth it, but is technically more accurate."] = "선택하면 애드온은 다른 주문의 시전을 위해 |T136163:0|t 영혼 흡수 주문의 정신 집중을 중단할 시기를 결정하는 데 |cFFFF0000더 많은 CPU|r를 소비합니다.  이것은 일반적으로 가치가 없지만 기술적으로 더 정확합니다."
L["|T136139:0|t Agony Macro"] = "|T136139:0|t 고통 매크로"
L["|T136118:0|t Corruption Macro"] = "|T136118:0|t 부패 매크로"
L["|T136188:0|t Siphon Life Macro"] = "|T136188:0|t 생명력 착취 매크로"
L["Using a macro makes it easier to apply your DoT effects to other targets without switching targets."] = "매크로를 사용하면 대상을 전환하지 않고도 주기적인 피해(DoT) 효과를 다른 대상에게 더 쉽게 적용할 수 있습니다."

L["Demonology"] = "악마"
L["Wild Imps Required"] = "|T2065628:0|t 악마 폭군 소환에 필요한 날뛰는 임프의 숫자"
L["If set above zero, |T2065628:0|t Summon Demonic Tyrant will not be recommended unless the specified number of imps are summoned.\n\nThis can backfire horribly, letting your Felguard or Vilefiend expire when you could've extended them with Summon Demonic Tyrant."] = "설정값을 0보다 높게 설정하면, 지정된 수의 임프가 소환되지 않으면 |T2065628:0|t 악마 폭군 소환을 추천하지 않습니다.\n\n이 설정은 악마 폭군 소환으로 연장될 수 있는 찰나에 지옥수호병이나 썩은마귀가 만료되는 끔찍한 역효과를 낼 수 있습니다."

L["Destruction"] = "파괴"
L["Preferred Demon"] = "선호하는 악마"
L["Specify which demon should be summoned if you have no active pet."] = "활성화된 소환수가 없는 경우에 소환할 악마를 지정합니다."
L["Require 3+ Targets for AOE"] = "광역에 필요한 3개 이상의 대상"
L["If checked, the default action list will only use its AOE action list (including |T%s:0|t Rain of Fire) when there are 3+ targets.\n\nIn multi-target Patchwerk simulations, this setting creates a significant DPS loss.  However, this option may be useful in real-world scenarios, especially if you are fighting two moving targets that will not stand in your Rain of Fire for the whole duration."] = "선택하면 기본 행동 목록은 대상이 3개 이상일 때 (|T%s:0|t 불의 비를 포함하여) 광역 행동 목록만 사용합니다.\n\n여러 대상에 대한 패치워크 시뮬레이션에서 이 설정은 상당한 DPS 손실을 만들었습니다.  그러나 이 옵션은 실제 시나리오에서 유용할 수 있으며, 특히 불의 비를 시전하는 전체 지속 시간 동안에 불의 비에 서 있지 않는 두 개의 움직이는 대상과 싸우는 경우에 유용합니다."
L["When %1$s is shown with a |TInterface\\Addons\\Hekili\\Textures\\Cycle:0|t indicator, the addon is recommending that you cast %2$s on a different target (without swapping).  A mouseover macro is useful for this and an example is included below."] = "%1$s|1이;가; |TInterface\\Addons\\Hekili\\Textures\\Cycle:0|t 표시기와 함께 표시되면, 애드온은 (대상 전환을 하지 않고) 다른 대상에게 %2$s|1을;를; 시전할 것을 추천합니다.  이를 위해 마우스오버 매크로가 유용하며 아래에 예제를 포함하고 있습니다."
L["Havoc"] = "대혼란"
L["Havoc Macro"] = "대혼란 매크로"
L["Immolate"] = "제물"
L["Immolate Macro"] = "제물 매크로"

end

------------------------------------------------------------------------
-- Warriror
------------------------------------------------------------------------

if UnitClassBase( "player" ) == "WARRIOR" then

L["Only |T236312:0|t Shockwave as Interrupt (when Talented)"] = "|T236312:0|t 충격파를 차단할 때만 사용 (특성 필요)"
L["If checked, |T236312:0|t Shockwave will only be recommended when your target is casting."] = "선택하면 대상이 시전 중일 때만 |T236312:0|t 충격파를 추천합니다."
L["Use Heroic Charge Combo"] = "영웅의 돌진 콤보 사용"
L["If checked, the default priority will check |cFFFFD100settings.heroic_charge|r to determine whether to use |T236171:0|t Heroic Leap + |T132337:0|t Charge together.\n\nThis is generally a DPS increase but the erratic movement can be disruptive to smooth gameplay."] = "선택하면 기본 우선순위는 |cFFFFD100settings.heroic_charge|r를 확인하여 |T236171:0|t 영웅의 도약 + |T132337:0|t 돌진을 함께 사용할지 여부를 결정합니다.\n\n이 옵션은 일반적으로 DPS가 증가하지만 불규칙한 움직임은 원활한 게임 플레이에 지장을 줄 수 있습니다."

L["Arms"] = "무기"

L["Fury"] = "분노"
L["Check |T132369:0|t Whirlwind Range"] = "|T132369:0|t 소용돌이 범위 확인"
L["If checked, when your target is outside of |T132369:0|t Whirlwind's range, it will not be recommended."] = "선택하면 대상이 |T132369:0|t 소용돌이의 사정거리를 벗어난 경우 추천하지 않습니다."

L["Protection Warrior"] = "방어"
L["Overlap |T1377132:0|t Ignore Pain"] = "|T1377132:0|t 고통 감내 중복 추천"
L["If checked, |T1377132:0|t Ignore Pain can be recommended while it is already active.  This setting may cause you to spend more Rage on mitigation."] = "선택하면 |T1377132:0|t 고통 감내가 이미 활성화되어 있는 동안 추천합니다.  이 설정으로 인하여 피해 완화에 더 많은 분노를 소비하게 됩니다."
L["Overlap |T132110:0|t Shield Block"] = "|T132110:0|t 방패 올리기 중복 추천"
L["If checked, the addon can recommend overlapping |T132110:0|t Shield Block usage.\n\nThis setting avoids leaving Shield Block at 2 charges, which wastes cooldown recovery time."] = "선택하면 애드온이 |T132110:0|t 방패 올리기의 사용을 중복해서 추천합니다.\n\n이 설정은 방패 올리기가 2회 충전된 상태로 남아 재사용 대기시간의 회복 시간을 낭비하는 것을 방지합니다."
L["Allow Stance Changes"] = "태세 변경 허용"
L["If checked, custom priorities can be written to recommend changing between stances.  For example, Battle Stance could be recommended when using offensive cooldowns, then Defensive Stance can be recommended when tanking resumes.\n\nIf left unchecked, the addon will not recommend changing your stance as long as you are already in a stance.  This choice prevents the addon from endlessly recommending that you change your stance when you do not want to change it."] = "선택하면 사용자 정의 우선순위를 작성하여 태세 간 변경을 추천할 수 있습니다.  예를 들어, 공격을 위한 재사용 대기시간 능력을 사용할 때 전투 태세를 추천할 수 있고, 방어 전담으로 재개하는 경우 방어 태세를 추천할 수 있습니다.\n\n선택하지 않은 상태로 두면, 애드온은 이미 태세를 취하고 있는 경우 태세 변경을 추천하지 않습니다.  이 선택은 플레이어가 태세를 변경하고 싶지 않을 때 애드온이 끝없이 태세를 변경하라고 추천하는 것을 방지합니다."
L["|T135726:0|t Reserve Rage for Mitigation"] = "|T135726:0|t 피해 완화를 위한 분노 비축"
L["If set above 0, the addon will not recommend |T132353:0|t Revenge or |T135358:0|t Execute unless you'll be still have this much Rage afterward.\n\nWhen set to |cFFFFD10035|r or higher, this feature ensures that you can always use |T1377132:0|t Ignore Pain and |T132110:0|t Shield Block when following recommendations for damage and threat."] = "설정값을 0보다 높게 설정하면, 나중에 이만큼의 분노를 가지지 않는 한 애드온은 |T132353:0|t 복수 또는 |T135358:0|t 마무리 일격을 추천하지 않습니다.\n\n이 기능을 |cFFFFD10035|r 또는 이상으로 설정하면, 피해 및 위협 수준에 대한 추천을 따르는 경우 항상 |T1377132:0|t 고통 감내와 |T132110:0|t 방패 올리기를 사용할 수 있습니다."
L["|T132362:0|t Shield Wall Damage Required"] = "|T132362:0|t 방패의 벽에 요구되는 피해량"
L["If set above 0, the addon will not recommend |T132362:0|t Shield Wall unless you have taken this much damage in the past 5 seconds, as a percentage of your maximum health.\n\nIf set to |cFFFFD10050%|r and your maximum health is 50,000, then the addon will only recommend Shield Wall when you've taken 25,000 damage in the past 5 seconds.\n\nThis value is reduced by 50% when playing solo."] = "설정값을 0보다 높게 설정하면, 지난 5초 동안 최대 체력의 백분율로 이 정도의 피해를 입지 않는 한 애드온은 |T132362:0|t 방패의 벽을 추천하지 않습니다.\n\n이 값을 |cFFFFD10050%|r로 설정하고 최대 체력이 50,000인 경우, 애드온은 지난 5초 동안 25,000의 피해를 입었을 때만 방패의 벽을 추천합니다.\n\n이 값은 혼자 플레이하는 경우 50%로 감소됩니다."
L["|T132362:0|t Shield Wall Health Percentage"] = "|T132362:0|t 방패의 벽에 요구되는 체력 백분율"
L["If set below 100, the addon will not recommend |T132362:0|t Shield Wall unless your current health has fallen below this percentage."] = "설정값을 100보다 낮게 설정하면, 애드온은 현재 체력이 이 비율 아래로 떨어지지 않는 한 |T132362:0|t 방패의 벽을 추천하지 않습니다."
L["Require |T132362:0|t Shield Wall Damage and Health"] = "|T132362:0|t 방패의 벽에 요구되는 피해량과 체력"
L["If checked, |T132362:0|t Shield Wall will not be recommended unless both the Damage Required |cFFFFD100and|r Health Percentage requirements are met.\n\nOtherwise, Shield Wall can be recommended when |cFFFFD100either|r requirement is met."] = "선택하면 필요한 피해량 |cFFFFD100및|r 체력 백분율에 대한 요구 사항이 모두 충족되지 않으면 |T132362:0|t 방패의 벽을 추천하지 않습니다.\n\n선택하지 않으면 요구 사항 중에서 |cFFFFD100한 가지라도|r 충족되면 방패의 벽을 추천합니다."
L["|T132351:0|t Rallying Cry Damage Required"] = "|T132351:0|t 재집결의 함성에 요구되는 피해량"
L["If set above 0, the addon will not recommend |T132351:0|t Rallying Cry unless you have taken this much damage in the past 5 seconds, as a percentage of your maximum health.\n\nIf set to |cFFFFD10050%|r and your maximum health is 50,000, then the addon will only recommend Rallying Cry when you've taken 25,000 damage in the past 5 seconds.\n\nThis value is reduced by 50% when playing solo."] = "설정값을 0보다 높게 설정하면, 지난 5초 동안 최대 체력의 백분율로 이 정도의 피해를 입지 않는 한 애드온은 |T132351:0|t 재집결의 함성을 추천하지 않습니다.\n\n이 값을 |cFFFFD10050%|r로 설정하고 최대 체력이 50,000인 경우, 애드온은 지난 5초 동안 25,000의 피해를 입었을 때만 재집결의 함성을 추천합니다.\n\n이 값은 혼자 플레이하는 경우 50%로 감소됩니다."
L["|T132351:0|t Rallying Cry Health Percentage"] = "|T132351:0|t 재집결의 함성에 요구되는 체력 백분율"
L["If set below 100, the addon will not recommend |T132351:0|t Rallying Cry unless your current health has fallen below this percentage."] = "설정값을 100보다 낮게 설정하면, 애드온은 현재 체력이 이 비율 아래로 떨어지지 않는 한 |T132351:0|t 재집결의 함성을 추천하지 않습니다."
L["Require |T132351:0|t Rallying Cry Damage and Health"] = "|T132351:0|t 재집결의 함성에 요구되는 피해량과 체력"
L["If checked, |T132351:0|t Rallying Cry will not be recommended unless both the Damage Required |cFFFFD100and|r Health Percentage requirements are met.\n\nOtherwise, Rallying Cry can be recommended when |cFFFFD100either|r requirement is met."] = "선택하면 필요한 피해량 |cFFFFD100및|r 체력 백분율에 대한 요구 사항이 모두 충족되지 않으면 |T132351:0|t 재집결의 함성을 추천하지 않습니다.\n\n선택하지 않으면 요구 사항 중에서 |cFFFFD100한 가지라도|r 충족되면 재집결의 함성을 추천합니다."
L["Use |T135871:0|t Last Stand Offensively"] = "|T135871:0|t 최후의 저항을 공격적으로 사용"
L["If checked, the addon will recommend using |T135871:0|t Last Stand to generate rage.\n\nIf unchecked, the addon will only recommend |T135871:0|t Last Stand defensively after taking significant damage.\n\nRequires |T571316:0|t Unnerving Focus %1$s or %2$s."] = "선택하면 애드온이 |T135871:0|t 최후의 저항을 사용하여 분노를 생성하도록 추천합니다.\n\n선택하지 않은 경우 애드온은 상당한 피해를 입은 후에만 |T135871:0|t 최후의 저항을 방어적으로 추천합니다.\n\n|T571316:0|t 불굴의 집중력 %1$s 또는 %2$s|1이;가; 필요합니다."
L["Talent"] = "특성"
L["Conduit"] = "도관"
L["|T135871:0|t Last Stand Damage Required"] = "|T135871:0|t 최후의 저항에 요구되는 피해량"
L["If set above 0, the addon will not recommend |T135871:0|t Last Stand unless you have taken this much damage in the past 5 seconds, as a percentage of your maximum health.\n\nIf set to |cFFFFD10050%|r and your maximum health is 50,000, then the addon will only recommend Last Stand when you've taken 25,000 damage in the past 5 seconds.\n\nThis value is reduced by 50% when playing solo."] = "설정값을 0보다 높게 설정하면, 지난 5초 동안 최대 체력의 백분율로 이 정도의 피해를 입지 않는 한 애드온은 |T135871:0|t 최후의 저항을 추천하지 않습니다.\n\n이 값을 |cFFFFD10050%|r로 설정하고 최대 체력이 50,000인 경우, 애드온은 지난 5초 동안 25,000의 피해를 입었을 때만 최후의 저항을 추천합니다.\n\n이 값은 혼자 플레이하는 경우 50%로 감소됩니다."
L["|T135871:0|t Last Stand Health Percentage"] = "|T135871:0|t 최후의 저항에 요구되는 체력 백분율"
L["If set below 100, the addon will not recommend |T135871:0|t Last Stand unless your current health has fallen below this percentage."] = "설정값을 100보다 낮게 설정하면, 애드온은 현재 체력이 이 비율 아래로 떨어지지 않는 한 |T135871:0|t 최후의 저항을 추천하지 않습니다."
L["Require |T135871:0|t Last Stand Damage and Health"] = "|T135871:0|t 최후의 저항에 요구되는 피해량과 체력"
L["If checked, |T135871:0|t Last Stand will not be recommended unless both the Damage Required |cFFFFD100and|r Health Percentage requirements are met.\n\nOtherwise, Last Stand can be recommended when |cFFFFD100either|r requirement is met."] = "선택하면 필요한 피해량 |cFFFFD100및|r 체력 백분율에 대한 요구 사항이 모두 충족되지 않으면 |T135871:0|t 최후의 저항을 추천하지 않습니다.\n\n선택하지 않으면 요구 사항 중에서 |cFFFFD100한 가지라도|r 충족되면 최후의 저항을 추천합니다."

end
