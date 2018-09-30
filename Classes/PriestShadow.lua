-- PriestShadow.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State


if UnitClassBase( 'player' ) == 'PRIEST' then
    local spec = Hekili:NewSpecialization( 258 )

    spec:RegisterResource( Enum.PowerType.Insanity, {
        mind_flay = {
            aura = 'mind_flay',
            debuff = true,

            last = function ()
                local app = state.debuff.mind_flay.applied
                local t = state.query_time

                return app + floor( t - app )
            end,

            interval = function () return class.auras.mind_flay.tick_time end,
            value = function () return ( state.talent.fortress_of_the_mind.enabled and 1.2 or 1 ) * 3 end,
        },

        mind_sear = {
            aura = 'mind_sear',
            debuff = true,

            last = function ()
                local app = state.debuff.mind_sear.applied
                local t = state.query_time

                return app + floor( t - app )
            end,

            interval = function () return class.auras.mind_sear.tick_time end,
            value = function () return ( state.talent.fortress_of_the_mind.enabled and 1.2 or 1 ) * 1.25 * state.active_enemies end,
        },

        -- need to revise the value of this, void decay ticks up and is impacted by void torrent.
        voidform = {
            aura = "voidform",

            last = function ()
                local app = state.buff.voidform.applied
                local t = state.query_time

                return app + floor( t - app )
            end,

            stop = function( x )
                return x == 0
            end,

            interval = 1,
            value = function ()
                return ( state.debuff.void_torrent.up or state.debuff.dispersion.up ) and 0 or ( -6 - ( 0.8 * state.debuff.voidform.stacks ) )
            end,
        },

        vamp_touch_t19 = {
            aura = "vampiric_touch",
            set_bonus = "tier19_2pc",
            debuff = true,

            last = function ()
                local app = state.debuff.vampiric_touch.applied
                local t = state.query_time

                return app + floor( t - app )
            end,

            interval = function () return state.debuff.vampiric_touch.tick_time end,
            value = 1
        }
    } )
    spec:RegisterResource( Enum.PowerType.Mana )
    
    -- Talents
    spec:RegisterTalents( {
        fortress_of_the_mind = 22328, -- 193195
        shadowy_insight = 22136, -- 162452
        shadow_word_void = 22314, -- 205351

        body_and_soul = 22315, -- 64129
        sanlayn = 23374, -- 199855
        mania = 21976, -- 193173

        twist_of_fate = 23125, -- 109142
        misery = 23126, -- 238558
        dark_void = 23127, -- 263346

        last_word = 23137, -- 263716
        mind_bomb = 23375, -- 205369
        psychic_horror = 21752, -- 64044

        auspicious_spirits = 22310, -- 155271
        shadow_word_death = 22311, -- 32379
        shadow_crash = 21755, -- 205385

        lingering_insanity = 21718, -- 199849
        mindbender = 21719, -- 200174
        void_torrent = 21720, -- 263165

        legacy_of_the_void = 21637, -- 193225
        dark_ascension = 21978, -- 280711
        surrender_to_madness = 21979, -- 193223
    } )

    -- PvP Talents
    spec:RegisterPvpTalents( { 
        gladiators_medallion = 3476, -- 208683
        adaptation = 3477, -- 214027
        relentless = 3478, -- 196029

        void_shift = 128, -- 108968
        hallucinations = 3736, -- 280752
        psychic_link = 119, -- 199484
        void_origins = 739, -- 228630
        mind_trauma = 113, -- 199445
        edge_of_insanity = 110, -- 199408
        driven_to_madness = 106, -- 199259
        pure_shadow = 103, -- 199131
        void_shield = 102, -- 280749
        psyfiend = 763, -- 211522
        shadow_mania = 764, -- 280750
    } )


    spec:RegisterHook( "reset_precast", function ()
        if buff.voidform.up then applyBuff( "shadowform" ) end
    end )


    -- Auras
    spec:RegisterAuras( {
        body_and_soul = {
            id = 65081,
            duration = 3,
            type = "Magic",
            max_stack = 1,
        },
        dispersion = {
            id = 47585,
            duration = 6,
            max_stack = 1,
        },
        fade = {
            id = 586,
            duration = 10,
            max_stack = 1,
        },
        levitate = {
            id = 111759,
            duration = 600,
            type = "Magic",
            max_stack = 1,
        },
        lingering_insanity = {
            id = 197937,
            duration = 60,
            max_stack = 8,
        },
        mind_bomb = {
            id = 226943,
            duration = 5,
            type = "Magic",
            max_stack = 1,
        },
        mind_flay = {
            id = 15407,
            duration = function () return 3 * haste end,
            max_stack = 1,
            tick_time = function () return 0.75 * haste end,
        },
        mind_sear = {
            id = 48045,
            duration = function () return 3 * haste end,
            max_stack = 1,
            tick_time = function () return 0.75 * haste end,
        },
        mind_vision = {
            id = 2096,
            duration = 60,
            max_stack = 1,
        },
        power_word_fortitude = {
            id = 21562,
            duration = 3600,
            type = "Magic",
            max_stack = 1,
            shared = "player", -- use anyone's buff on the player, not just player's.
        },
        power_word_shield = {
            id = 17,
            duration = 15,
            type = "Magic",
            max_stack = 1,
        },
        psychic_horror = {
            id = 64044,
            duration = 4,
            type = "Magic",
            max_stack = 1,
        },
        psychic_scream = {
            id = 8122,
            duration = 8,
            type = "Magic",
            max_stack = 1,
        },
        shackle_undead = {
            id = 9484,
            duration = 50,
            type = "Magic",
            max_stack = 1,
        },
        shadow_word_pain = {
            id = 589,
            duration = 16,
            type = "Magic",
            max_stack = 1,
            tick_time = function () return 2 * haste end,
        },
        shadowform = {
            id = 232698,
            duration = 3600,
            max_stack = 1,
        },
        shadowy_apparitions = {
            id = 78203,
        },
        shadowy_insight = {
            id = 124430,
            duration = 12,
            type = "Magic",
            max_stack = 1,
        },
        silence = {
            id = 15487,
            duration = 4,
            type = "Magic",
            max_stack = 1,
        },
        surrender_to_madness = {
            id = 193223,
            duration = 60,
            max_stack = 1,
        },
        surrendered_to_madness = {
            id = 263406,
            duration = 30,
            max_stack = 1,
        },
        vampiric_embrace = {
            id = 15286,
            duration = 15,
            max_stack = 1,
        },
        vampiric_touch = {
            id = 34914,
            duration = 21,
            type = "Magic",
            max_stack = 1,
            tick_time = function () return 3 * haste end,
        },
        void_bolt = {
            id = 228266,
        },
        void_torrent = {
            id = 263165,
            duration = 4,
            max_stack = 1,
            tick_time = 1,
        },
        voidform = {
            id = 194249,
            duration = 3600,
            max_stack = 99,
            meta = {
                drop_time = function ()
                    if buff.voidform.down then return query_time end

                    local app = buff.voidform.applied
                    app = app + floor( query_time - app )

                    local drain = 6 + ( 0.8 * buff.voidform.stacks )
                    local amt = insanity.current

                    while ( amt > 0 ) do
                        amt = amt - drain
                        drain = drain + 0.8
                        app = app + 1
                    end

                    return app
                end,

                stacks = function ()
                    return buff.voidform.up and ( buff.voidform.count + floor( offset + delay ) ) or 0
                end,

                remains = function ()                    
                    return buff.voidform.drop_time - query_time
                end,
            },
        },
    } )


    spec:RegisterHook( "advance_end", function ()
        if buff.voidform.up and insanity.current == 0 then
            removeBuff( "voidform" )
            applyBuff( "shadowform" )
        end
    end )


    spec:RegisterGear( "tier21", 152154, 152155, 152156, 152157, 152158, 152159 )
    spec:RegisterGear( "tier20", 147163, 147164, 147165, 147166, 147167, 147168 )
        spec:RegisterAura( "empty_mind", {
            id = 247226,
            duration = 12,
            max_stack = 10,
        } )
    spec:RegisterGear( "tier19", 138310, 138313, 138316, 138319, 138322, 138370 )

    
    spec:RegisterGear( "anunds_seared_shackles", 132409 )
        spec:RegisterAura( "anunds_last_breath", {
            id = 215210,
            duration = 15,
            max_stack = 50,
        } )
    spec:RegisterGear( "heart_of_the_void", 151814 )
    spec:RegisterGear( "mangazas_madness", 132864 )
    spec:RegisterGear( "mother_shahrazs_seduction", 132437 )
    spec:RegisterGear( "soul_of_the_high_priest", 151646 )
    spec:RegisterGear( "the_twins_painful_touch", 133973 )
    spec:RegisterGear( "zenkaram_iridis_anadem", 133971 )
    spec:RegisterGear( "zeks_exterminatus", 144438 )
        spec:RegisterAura( "zeks_exterminatus", {
            id = 236546,
            duration = 15,
            max_stack = 1,
        } )


    -- Abilities
    spec:RegisterAbilities( {
        dark_ascension = {
            id = 280711,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            spend = -50,
            spendType = "insanity",
            
            toggle = "cooldowns",

            startsCombat = true,
            texture = 1711336,

            talent = "dark_ascension",
            
            handler = function ()
                applyBuff( "voidform", nil, ( level < 116 and equipped.mother_shahrazs_seduction ) and 3 or 1 )
            end,
        },
        

        dark_void = {
            id = 263346,
            cast = 2,
            cooldown = 30,
            gcd = "spell",
            
            startsCombat = true,
            texture = 132851,

            talent = "dark_void",
            
            handler = function ()
                applyDebuff( "target", "shadow_word_pain" )
                active_dot.shadow_word_pain = max( active_dot.shadow_word_pain, active_enemies )
            end,
        },
        

        dispel_magic = {
            id = 528,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0.04,
            spendType = "mana",
            
            startsCombat = true,
            texture = 136066,
            
            usable = function () return debuff.dispellable_magic.up end,
            handler = function ()
                removeDebuff( "target", "dispellable_magic" )
            end,
        },
        

        dispersion = {
            id = 47585,
            cast = 0,
            cooldown = 120,
            gcd = "spell",
            
            toggle = "defensives",
            defensive = true,

            startsCombat = false,
            texture = 237563,
            
            handler = function ()
                applyBuff( "dispersion" )
                setCooldown( "global_cooldown", 6 )
            end,
        },
        

        fade = {
            id = 586,
            cast = 0,
            cooldown = 30,
            gcd = "spell",
            
            startsCombat = true,
            texture = 135994,
            
            handler = function ()
                applyBuff( "fade" )
            end,
        },
        

        leap_of_faith = {
            id = 73325,
            cast = 0,
            cooldown = 90,
            gcd = "spell",
            
            spend = 0.03,
            spendType = "mana",
            
            startsCombat = false,
            texture = 463835,
            
            handler = function ()
            end,
        },
        

        levitate = {
            id = 1706,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0.01,
            spendType = "mana",
            
            startsCombat = true,
            texture = 135928,
            
            handler = function ()
                applyBuff( "levitate" )
            end,
        },
        

        mass_dispel = {
            id = 32375,
            cast = 1.5,
            cooldown = 45,
            gcd = "spell",
            
            spend = 0.08,
            spendType = "mana",
            
            startsCombat = true,
            texture = 135739,
            
            usable = function () return debuff.dispellable_magic.up end,
            handler = function ()
                removeDebuff( "target", "dispellable_magic" )
            end,
        },
        

        -- SimulationCraft module for Shadow Word: Void automatically substitutes SW:V for MB when talented.
        mind_blast = {
            id = function () return talent.shadow_word_void.enabled and 205351 or 8092 end,
            cast = function () return haste * ( buff.shadowy_insight.up and 0 or 1.5 ) end,
            charges = function ()
                local n = 1
                if talent.shadow_word_void.enabled then n = n + 1 end
                if level < 116 and equipped.mangazas_madness then n = n + 1 end
                return n > 1 and n or nil
            end,
            cooldown = function () return ( talent.shadow_word_void.enabled and 9 or 7.5 ) * haste end,
            recharge = function () return ( talent.shadow_word_void.enabled and 9 or 7.5 ) * haste end,
            gcd = "spell",

            velocity = 15,

            spend = function () return ( talent.fortress_of_the_mind.enabled and 1.2 or 1 ) * ( ( talent.shadow_word_void.enabled and -15 or -12 ) - buff.empty_mind.stack ) * ( buff.surrender_to_madness.up and 2 or 1 ) * ( debuff.surrendered_to_madness.up and 0 or 1 ) end,
            spendType = "insanity",
            
            startsCombat = true,
            texture = function () return talent.shadow_word_void.enabled and 610679 or 136224 end,

            -- notalent = "shadow_word_void",
            
            handler = function ()
                removeBuff( "shadowy_insight" )
                removeBuff( "empty_mind" )
            end,

            copy = { "shadow_word_void", 205351 }
        },


        --[[ shadow_word_void = {
            id = 205351,
            cast = 1.5,
            charges = 2,
            cooldown = 9,
            recharge = 9,
            hasteCD = true,
            gcd = "spell",

            velocity = 15,

            spend = function () return ( talent.fortress_of_the_mind.enabled and 1.2 or 1 ) * ( -15 - buff.empty_mind.stack ) * ( buff.surrender_to_madness.up and 2 or 1 ) * ( debuff.surrendered_to_madness.up and 0 or 1 ) end,
            spendType = "insanity",
            
            startsCombat = true,
            texture = 610679,

            talent = "shadow_word_void",
            
            handler = function ()
                -- applies voidform (194249)
                -- applies mind_flay (15407)
                -- removes shadow_word_pain (589)
            end,
        }, ]]
        

        mind_bomb = {
            id = 205369,
            cast = 0,
            cooldown = 30,
            gcd = "spell",
            
            startsCombat = true,
            texture = 136173,

            talent = "mind_bomb",
            
            handler = function ()
                applyDebuff( "target", "mind_bomb" )
            end,
        },
        

        --[[ mind_control = {
            id = 605,
            cast = 1.8,
            cooldown = 0,
            gcd = "spell",
            
            spend = 100,
            spendType = "mana",
            
            startsCombat = true,
            texture = 136206,
            
            handler = function ()
            end,
        }, ]]
        

        mind_flay = {
            id = 15407,
            cast = 3,
            cooldown = 0,
            gcd = "spell",

            spend = 0,
            spendType = "insanity",

            channeled = true,
            breakable = true,
            breakchannel = function ()
                removeDebuff( "target", "mind_flay" )
            end,
            prechannel = true,

            startsCombat = true,
            texture = 136208,

            aura = 'mind_flay',

            handler = function ()
                applyDebuff( "target", "mind_flay" )
                channelSpell( "mind_flay" )
                if level < 116 then
                    if equipped.the_twins_painful_touch and action.mind_flay.lastCast < max( action.dark_ascension.lastCast, action.void_eruption.lastCast ) then
                        if debuff.shadow_word_pain.up and active_dot.shadow_word_pain < min( 4, active_enemies ) then
                            active_dot.shadow_word_pain = min( 4, active_enemies )
                        end
                        if debuff.vampiric_touch.up and active_dot.vampiric_touch < min( 4, active_enemies ) then
                            active_dot.vampiric_touch = min( 4, active_enemies )
                        end
                    end

                    if set_bonus.tier20_2pc == 1 then
                        addStack( "empty_mind", nil, 3 )
                    end
                end
            end,
        },
        

        mind_sear = {
            id = 48045,
            cast = 3,
            cooldown = 0,
            gcd = "spell",

            spend = 0,
            spendType = "insanity",
            
            channeled = true,
            breakable = true,
            breakchannel = function ()
                removeDebuff( "target", "mind_sear" )
            end,
            prechannel = true,

            startsCombat = true,
            texture = 237565,

            aura = 'mind_sear',
            
            handler = function ()
                applyDebuff( "target", "mind_sear" )
                channelSpell( "mind_sear" )
            end,
        },
        

        --[[ mind_vision = {
            id = 2096,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0.01,
            spendType = "mana",
            
            startsCombat = true,
            texture = 135934,
            
            handler = function ()
                -- applies mind_vision (2096)
            end,
        }, ]]
        

        mindbender = {
            id = 200174,
            cast = 0,
            cooldown = 60,
            gcd = "spell",
            
            toggle = "cooldowns",

            startsCombat = true,
            texture = 136214,

            talent = "mindbender",
            
            handler = function ()
                summonPet( "mindbender", 15 )
            end,
        },
        

        power_word_fortitude = {
            id = 21562,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0.04,
            spendType = "mana",
            
            startsCombat = false,
            texture = 135987,
            
            usable = function () return buff.power_word_fortitude.down end,
            handler = function ()
                applyBuff( "power_word_fortitude" )
            end,
        },
        

        power_word_shield = {
            id = 17,
            cast = 0,
            cooldown = 6,
            hasteCD = true,
            gcd = "spell",
            
            spend = 0.02,
            spendType = "mana",
            
            startsCombat = false,
            texture = 135940,
            
            handler = function ()
                applyBuff( "power_word_shield" )
                if talent.body_and_soul.enabled then applyBuff( "power_word_shield" ) end
            end,
        },
        

        psychic_horror = {
            id = 64044,
            cast = 0,
            cooldown = 45,
            gcd = "spell",
            
            startsCombat = true,
            texture = 237568,

            talent = "psychic_horror",
            
            handler = function ()
                applyDebuff( "target", "psychic_horror" )
            end,
        },
        

        psychic_scream = {
            id = 8122,
            cast = 0,
            cooldown = 60,
            gcd = "spell",
            
            spend = 0.03,
            spendType = "mana",
            
            startsCombat = true,
            texture = 136184,

            notalent = "mind_bomb",
            
            handler = function ()
                applyDebuff( "target", "psychic_scream" )
            end,
        },
        

        --[[ purify_disease = {
            id = 213634,
            cast = 0,
            charges = 1,
            cooldown = 8,
            recharge = 8,
            gcd = "spell",
            
            spend = 0.01,
            spendType = "mana",
            
            startsCombat = true,
            texture = 135935,
            
            handler = function ()
            end,
        },
        

        resurrection = {
            id = 2006,
            cast = 10,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0.01,
            spendType = "mana",
            
            startsCombat = true,
            texture = 135955,
            
            handler = function ()
            end,
        }, ]]
        

        shackle_undead = {
            id = 9484,
            cast = 1.5,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0.04,
            spendType = "mana",
            
            startsCombat = true,
            texture = 136091,
            
            handler = function ()
                applyDebuff( "target", "shackle_undead" )
            end,
        },
        

        shadow_crash = {
            id = 205385,
            cast = 0,
            cooldown = 20,
            gcd = "spell",
            
            startsCombat = true,
            texture = 136201,
            
            handler = function ()
            end,
        },
        

        shadow_mend = {
            id = 186263,
            cast = 1.5,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0.03,
            spendType = "mana",
            
            startsCombat = true,
            texture = 136202,
            
            handler = function ()
            end,
        },
        

        shadow_word_death = {
            id = 32379,
            cast = 0,
            charges = 2,
            cooldown = 9,
            recharge = 9,
            gcd = "spell",

            spend = 15,
            spendType = "insanity",
            
            startsCombat = true,
            texture = 136149,

            talent = "shadow_word_death",
            
            usable = function () return buff.zeks_exterminatus.up or target.health.pct < 20 end,
            handler = function ()
                removeBuff( "zeks_exterminatus" )
            end,
        },
        

        shadow_word_pain = {
            id = 589,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = -4,
            spendType = "insanity",
            
            startsCombat = true,
            texture = 136207,

            cycle = "shadow_word_pain",
            
            handler = function ()
                applyDebuff( "target", "shadow_word_pain" )
            end,
        },
        

        shadow_word_void = {
            id = 205351,
            cast = 1.5,
            charges = 2,
            cooldown = 9,
            recharge = 9,
            hasteCD = true,
            gcd = "spell",

            velocity = 15,

            spend = function () return ( talent.fortress_of_the_mind.enabled and 1.2 or 1 ) * ( -15 - buff.empty_mind.stack ) * ( buff.surrender_to_madness.up and 2 or 1 ) * ( debuff.surrendered_to_madness.up and 0 or 1 ) end,
            spendType = "insanity",
            
            startsCombat = true,
            texture = 610679,

            talent = "shadow_word_void",
            
            handler = function ()
                -- applies voidform (194249)
                -- applies mind_flay (15407)
                -- removes shadow_word_pain (589)
            end,
        },
        

        shadowfiend = {
            id = 34433,
            cast = 0,
            cooldown = 180,
            gcd = "spell",
            
            toggle = "cooldowns",

            startsCombat = true,
            texture = 136199,
            
            handler = function ()
            end,
        },
        

        shadowform = {
            id = 232698,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            startsCombat = false,
            texture = 136200,

            essential = true,
            nobuff = 'shadowform',

            handler = function ()
                applyBuff( "shadowform" )
            end,
        },
        

        silence = {
            id = 15487,
            cast = 0,
            cooldown = 45,
            gcd = "off",
            
            startsCombat = true,
            texture = 458230,
            
            toggle = "interrupts",
            interrupt = true,

            usable = function () return target.casting end,
            handler = function ()
                interrupt()
                applyDebuff( "target", "silence" )
            end,
        },
        

        surrender_to_madness = {
            id = 193223,
            cast = 0,
            cooldown = 240,
            gcd = "spell",
            
            toggle = "cooldowns",

            startsCombat = true,
            texture = 254090,
            
            handler = function ()
                applyBuff( "surrender_to_madness" )
            end,
        },
        

        vampiric_embrace = {
            id = 15286,
            cast = 0,
            cooldown = 120,
            gcd = "spell",
            
            startsCombat = false,
            texture = 136230,
            
            handler = function ()
                applyBuff( "vampiric_embrace" )
            end,
        },
        

        vampiric_touch = {
            id = 34914,
            cast = 1.5,
            cooldown = 0,
            gcd = "spell",

            spend = -6,
            spendType = "insanity",
            
            startsCombat = true,
            texture = 135978,

            cycle = 'vampiric_touch',
            
            handler = function ()
                applyDebuff( "target", "vampiric_touch" )
                if talent.misery.enabled then
                    applyDebuff( "target", "shadow_word_pain" )
                end
            end,
        },
        

        void_bolt = {
            id = 205448,
            known = 228260,
            cast = 0,
            cooldown = function ()
                if level < 116 and set_bonus.tier19_4pc > 0 and query_time - buff.voidform.applied < 2.5 then return 0 end
                return haste * 4.5
            end,
            gcd = "spell",

            spend = function ()
                if debuff.surrendered_to_madness.up then return 0 end
                return buff.surrender_to_madness.up and -32 or -16
            end,
            spendType = "insanity",
            
            startsCombat = true,
            texture = 1035040,
            
            velocity = 40,
            buff = "voidform",
            bind = "void_eruption",

            handler = function ()
                if debuff.shadow_word_pain.up then debuff.shadow_word_pain.expires = debuff.shadow_word_pain.expires + 3 end
                if debuff.vampiric_touch.up then debuff.vampiric_touch.expires = debuff.vampiric_touch.expires + 3 end
                removeBuff( "anunds_last_breath" )
            end,
        },
        

        void_eruption = {
            id = 228260,
            cast = function () return haste * ( talent.legacy_of_the_void.enabled and 0.6 or 1 ) * 2.5 end,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0,
            spendType = "insanity",
            
            startsCombat = true,
            texture = 1386548,

            nobuff = "voidform",
            bind = "void_bolt",
            
            usable = function () return insanity.current >= ( talent.legacy_of_the_void.enabled and 60 or 90 ) end,
            handler = function ()
                applyBuff( "voidform", nil, ( level < 116 and equipped.mother_shahrazs_seduction ) and 3 or 1 )
            end,
        },
        

        void_torrent = {
            id = 263165,
            cast = 4,
            channeled = true,
            fixedCast = true,
            cooldown = 45,
            gcd = "spell",
            
            startsCombat = true,
            texture = 1386551,

            aura = "void_torrent",
            talent = "void_torrent",
            buff = "voidform",

            handler = function ()
                applyDebuff( "target", "void_torrent" )
            end,
        },
    } )


    spec:RegisterOptions( {
        enabled = true,

        aoe = 3,
    
        nameplates = false,
        nameplateRange = 8,
        
        damage = true,
        damageExpiration = 6,
    
        potion = "potion_of_rising_death",
        
        package = "Shadow",
    } )


    spec:RegisterPack( "Shadow", 20180930.1615, [[d8ZcLaWBfFwOSjqv7sWRrs2hO4PICEKuMTunFqLtt1VqkFdjuRdqj7uPQ9kz3QSFkgfGQ)kQXPurpcqXqrczWanCaoiivLtbs5ycvNtPcTqqYsbuQfdLLd5HkvGvPubzzsbphXLrnvPOjRQPt6Ikvq9ka5ziP66sPTHe0JP0MfY2vkhMywGstdjY8qI67G42q1OvIXdsvojivv3cjW1uQ09usRePAysHoeivUIxnR0lkx7BOX47SXDK6ngIVZ4umL2XkPudaxjaILkjgxPtW5kLwKFGujac16J8vZkrMwKLR0IQaialA0I56slwWo40ioEBxuFolsIuAeh3sdRpy0WIek45nAaqtK3zcnkcXaBXFcnkcyNPiKZenNwKFGeioUTsyTExH(VcRsVOCTVHgJVZg3rQ3yi(oJtHns9kjT6YGQuYX3bv6zITsaJbmTi)aXasriNjQHoWyaxufabyrJwmxxAXc2bNgXXB7I6ZzrsKsJ44wAy9bJgwKqbpVrdaAI8otOrrigyl(tOrra7mfHCMO50I8dKaXXTg6aJbmXaughJrgqQ3iSgWgAm(onGuGbmofdSOuJg6g6aJbChSixmMaSm0bgdifyaH((NFdyY78z5GHoWyaPad4oyUngP8BavbfJ1Shzaju7ub6fQu3jkPAwjIFX6C1S2hVAwjXQ(CvAB8pZOwaQpxL4tW68xqvATVHQzL4tW68xqvjlYvg5sLWAJIcBJ)rdcp8dKRsIv95Q0liQYcXYhXNR0Ap1RMvsSQpxL2g)ZytxReFcwN)cQsR9uQAwj(eSo)fuvYICLrUujvqXynOooN1j)oBaPSbK6gq4GZaANP)dKlqwKFGKHmOp)SOlb7IGIXed4QbSbdiCWzabUb0ot)hixGSi)ajdzqF(zrxc2fbfJjgWvdyCdi8gq7m9FGCbYI8dKmKb95NfDjGyCXpIbKYgWy2pGlqpdi0QKyvFUkrwKFGKHmOp)SOlLw73TAwj(eSo)fuvYICLrUujS2OOW24F0GWdevSuzaHz1acCdy8DnGazaXAJIcy9z(ElrdTamGqZacVbufumwdQJZzDYVZgqymGn0yJgq4GZaQckgRb1X5So53zdiLnGu8UvsSQpxLiTieFpJY6KXL)ycP0ApfwnReFcwN)cQkzrUYixQes8pZB8Pb5FsWpdimgW4nwjXQ(Cv6fev5TX)sR9uC1SsIv95QeUFpgFpJQeFcwN)cQsR97SAwj(eSo)fuvYICLrUujOZaI1gff2g)JgeEOfGbeo4mGa3aANP)dKlqwKFGKHmOp)SOlb7IGIXed4QbSbdi8gqS2OOW24F0GWdevSuzaPSbm(UgqOvjXQ(CvISi)ajdzqF(zrxkT2VJvZkXNG15VGQswKRmYLkHe)Z8gFAq(Ne8ZacJbCxdi8gqK4FM34tdY)KW3Ie1NZaszdydnwjXQ(CvISi)ajBrczP0AF8gRMvIpbRZFbvLSixzKlvAtqUG15Wpkj3cOsIv95QeUFFgRleT0AF84vZkXNG15VGQswKRmYLk9JgilYpqYqg0Nbi(fqmU4hXacJbKsgq4nG)OHnbhGJCBwNw7saX4IFedimgqkvjXQ(CvAB8pRdcXNwATpEdvZkXNG15VGQswKRmYLkH4ietweSoBaH3aQckgRb1X5So53zdimgqkzaH3acDgqv68PbCNWiQf4tW68BaH3acDgqv68PHxquL3g)d8jyD(RKyvFUkrwKFGKHmOpdq8R0AFCQxnReFcwN)cQkzrUYixQeIJqmzrW6SbeEdOkOySguhNZ6KFNnGWyaPqdiCWzabUbuLoFAa3jmIAb(eSo)gq4nG)ObYI8dKmKb9zaIFbehHyYIG1zdi0QKyvFUkTj4aCKBZ60AxkT2hNsvZkXNG15VGQsIv95QeUFFoQluRs(Pmc1cqZEuLu3sfbM1gGh42z6)a5cBJ)zSPRHwaWbNDM(pqUaUFFgRlen0caAvYpLrOwaA2XX53fLRu8kzxe)Qu8sR9X3TAwjXQ(CvISi)ajdzqFgG4xL4tW68xqvAPv65iPTRvZAF8QzLeR6ZvjI35ZYvIpbRZFbvP1(gQMvsSQpxLAjC2vgNuj(eSo)fuLw7PE1Ss8jyD(lOQKf5kJCPsyTrrbS(mFVLObelw1achCgqvqXynOooN1j)oBaP8QbCNnAaHdodOkOySgwyPRlbaw1aszdi13TsIv95QeGr95kT2tPQzL4tW68xqvPbqLiSwjXQ(CvAtqUG15kTj9wUs)ObYI8dKmKb9zaIFb1Tu5xmdi8gWF0WMGdWrUnRtRDjOULk)IvPnbLpbNR0pkj3cO0A)UvZkjw1NRsymIWiQ8lwL4tW68xqvATNcRMvIpbRZFbvLSixzKlvIaG79SkOySsc4(9zclidimgqGBa31acKbmUbChYaQsNpnG7egrTaFcwNFdi0QKyvFUkHAVSyvFUC3jAL6orZNGZvsgU0ApfxnReFcwN)cQkzrUYixQKyvFJZ8X4otmGWyaJxjXQ(Cvc1EzXQ(C5Ut0k1DIMpbNRKTZYgxATFNvZkXNG15VGQswKRmYLkjw134mFmUZed4QbmELeR6Zvju7LfR6ZL7orRu3jA(eCUse)I15slTsaqSDWXeTAw7JxnReFcwN)cQsR9nunReFcwN)cQsR9uVAwj(eSo)fuLw7Pu1Ss8jyD(lOkT2VB1SsIv95QeGr95QeFcwN)cQsR9uy1Ss8jyD(lOQKf5kJCPsqNbeRnkkqwKFGeni8qlGkjw1NRsKf5hirdcV0ApfxnRKyvFUkH73NX6crReFcwN)cQsR97SAwjXQ(Cvc3VpJ1fIwj(eSo)fuLwALKHRM1(4vZkjw1NRsBJ)zg1cq95QeFcwN)cQsR9nunReFcwN)cQkzrUYixQewBuuyB8pAq4HFGCvsSQpxLEbrvwiw(i(CLw7PE1Ss8jyD(lOQKf5kJCPsQ05tdVGOkVn(h4tW68BaH3a(JgilYpqYqg0Nbi(fqmU4hXacJburYg3ZQJZvsSQpxL2g)ZytxlT2tPQzL4tW68xqvjlYvg5sLWAJIcBJ)rdcpquXsLbeMvdiWnGX31acKbeRnkkG1N57Ten0cWacTkjw1NRsKweIVNrzDY4YFmHuATF3QzL4tW68xqvjlYvg5sLqI)zEJpni)tc(zaHXagVXkjw1NRsVGOkVn(xATNcRMvsSQpxLW97X47zuL4tW68xqvATNIRMvIpbRZFbvLSixzKlvcj(N5n(0G8pj4Nbegd4Ugq4nGiX)mVXNgK)jHVfjQpNbKYgWgASsIv95Qezr(bs2IeYsP1(DwnReFcwN)cQkjw1NRs4(9zclOk5NYiulan7rvsDlveywBaEGBNP)dKlSn(NXMUgAbahC2z6)a5c4(9zSUq0qlaOvj)ugHAbOzhhNFxuUsXRKDr8RsXlT2VJvZkjw1NRsKf5hizid6Zae)QeFcwN)cQslTs2olBC1S2hVAwjXQ(CvAB8pZOwaQpxL4tW68xqvATVHQzL4tW68xqvjlYvg5sLWAJIcBJ)rdcp8dKRsIv95Q0liQYcXYhXNR0Ap1RMvsSQpxL2g)ZytxReFcwN)cQsR9uQAwj(eSo)fuvYICLrUujvqXynOooN1j)oBaPSbK6gq4GZaI1gff2g)JgeE4hixLeR6ZvjYI8dKmKb95NfDP0A)UvZkXNG15VGQswKRmYLkH1gff2g)JgeEGOILkdimRgqGBaJVRbeidiwBuuaRpZ3BjAOfGbeAvsSQpxLiTieFpJY6KXL)ycP0ApfwnReFcwN)cQkzrUYixQes8pZB8Pb5FsWpdimgW4nwjXQ(Cv6fev5TX)sR9uC1SsIv95QeUFpgFpJQeFcwN)cQsR97SAwjXQ(Cvc3VpJ1fIwj(eSo)fuLw73XQzL4tW68xqvjlYvg5sLaUbej(N5n(0G8pj4Nbegd4Ugq4nGiX)mVXNgK)jHVfjQpNbKYgWgmGqZachCgqK4FM34tdY)KW3Ie1NZacJbSHkjw1NRsKf5hizlsilLw7J3y1Ss8jyD(lOQKf5kJCPsiocXKfbRZgq4nGQGIXAqDCoRt(D2acJbKsgq4nGa3acDgqv68PbCNWiQf4tW68BaH3acDgqv68PHxquL3g)d8jyD(nGqRsIv95Qezr(bsgYG(maXVsR9XJxnReFcwN)cQkzrUYixQeIJqmzrW6SbeEdiWnGQGIXAqDCoRt(D2acJbKcnGqRsIv95Q0MGdWrUnRtRDP0AF8gQMvIpbRZFbvLSixzKlv6hnqwKFGKHmOpdq8lG4ietweSoBaH3acCdOkD(0aUtye1c8jyD(nGWBavbfJ1G64CwN87SbegdiLmGqRsIv95Q0MGdWrUnRtRDP0AFCQxnRKyvFUkTn(N1bH4tReFcwN)cQsR9XPu1Ss8jyD(lOQKyvFUkH73NjSGQKFkJqTa0kfVswKRmYLkraW9EwfumwjbC)(mHfKbegdydvYUi(vP4Lw7JVB1Ss8jyD(lOQKyvFUkH73NJ6c1QKFkJqTa0Shvj1TurGzTb4bUDM(pqUW24FgB6AOfaCWzNP)dKlG73NX6crdTaGwL8tzeQfGMDCC(Dr5kfVs2fXVkfV0AFCkSAwjXQ(CvISi)ajdzqFgG4xL4tW68xqvAPLwPngr85Q9n0y8D24os9gdXPykTBLGiOZVyKkb9Jdyqk)gWDnGIv95mGDNOKGHELiayBTVHD3zLaGMiVZvcymGPf5higqkc5mrn0bgd4IQaialA0I56slwWo40ioEBxuFolsIuAeh3sdRpy0WIek45nAaqtK3zcnkcXaBXFcnkcyNPiKZenNwKFGeioU1qhymGjgGY4ymYas9gH1a2qJX3PbKcmGXPyGfLA0q3qhymG7Gf5IXeGLHoWyaPadi03)8BatENplhm0bgdifya3bZTXiLFdOkOySM9idiHANkqVGHUHoWya3HHESTv53aIXrdInG2bhtudighZpsWac9zTmaLyaV5OGfbHh12nGIv95igW56ulyOlw1NJeaGy7GJj6AuxiuzOlw1NJeaGy7GJjkqR0IM5n0fR6ZrcaqSDWXefOvAsBmC(ur95m0bgdy6eaKLrnGiXFdiwBue)gqIkkXaIXrdInG2bhtudighZpIbuU3acaXuaGrv)IzaDIb8NJdg6Iv95ibai2o4yIc0knYjailJMjQOedDXQ(CKaaeBhCmrbALgGr95m0fR6ZrcaqSDWXefOvAKf5hirdchwpAf6WAJIcKf5hirdcp0cWqxSQphjaaX2bhtuGwPH73NX6crn0fR6ZrcaqSDWXefOvAKf5hizid6ZBJ)g6g6aJbChg6X2wLFdiVXiQzavhNnG6cBafRoidOtmGYM4DbRZbdDXQ(CKvI35ZYg6Iv95iaTsRLWzxzCIHUyvFocqR0amQphSE0kwBuuaRpZ3BjAaXIvHdovqXynOooN1j)ot51D2iCWPckgRHfw66saGvPm131qxSQphbOvABcYfSod7j486pkj3ca2bWkHvy3KElV(JgilYpqYqg0Nbi(fu3sLFXG)hnSj4aCKBZ60AxcQBPYVyg6Iv95iaTsdJregrLFXm0fR6ZraALgQ9YIv95YDNOWEcoVkddRhTsaW9EwfumwjbC)(mHfemaFxGIVdPsNpnG7egrTaFcwNFOzOlw1NJa0knu7LfR6ZL7orH9eCE12zzJH1JwfR6BCMpg3zcmXn0fR6ZraALgQ9YIv95YDNOWEcoVs8lwNH1JwfR6BCMpg3zYACdDdDXQ(CKGm8624FMrTauFodDXQ(CKGmmqR0Ebrvwiw(i(CW6rRyTrrHTX)ObHh(bYzOlw1NJeKHbAL224FgB6kSE0QkD(0WliQYBJ)b(eSo)W)JgilYpqYqg0Nbi(fqmU4hbgfjBCpRooBOlw1NJeKHbALgPfH47zuwNmU8htiW6rRyTrrHTX)ObHhiQyPcMvGhFxGWAJIcy9z(ElrdTaGMHUyvFosqggOvAVGOkVn(dRhTIe)Z8gFAq(Ne8dM4nAOlw1NJeKHbALgUFpgFpJm0fR6ZrcYWaTsJSi)ajBrczbwpAfj(N5n(0G8pj4hm7cps8pZB8Pb5Fs4BrI6Zr5gA0qxSQphjidd0knC)(mHfeS2fXV14W6NYiulan74487IYRXH1pLrOwaA2Jwv3sfbM1gGh42z6)a5cBJ)zSPRHwaWbNDM(pqUaUFFgRlen0caAg6Iv95ibzyGwPrwKFGKHmOpdq8Zq3qxSQphjy7SSXRBJ)zg1cq95m0fR6Zrc2olBmqR0Ebrvwiw(i(CW6rRyTrrHTX)ObHh(bYzOlw1NJeSDw2yGwPTn(NXMUAOlw1NJeSDw2yGwPrwKFGKHmOp)SOlW6rRQGIXAqDCoRt(DMYuho4WAJIcBJ)rdcp8dKZqxSQphjy7SSXaTsJ0Iq89mkRtgx(Jjey9OvS2OOW24F0GWdevSubZkWJVlqyTrrbS(mFVLOHwaqZqxSQphjy7SSXaTs7fev5TXFy9OvK4FM34tdY)KGFWeVrdDXQ(CKGTZYgd0knC)Em(EgzOlw1NJeSDw2yGwPH73NX6crn0fR6Zrc2olBmqR0ilYpqYwKqwG1Jwbos8pZB8Pb5FsWpy2fEK4FM34tdY)KW3Ie1NJYnan4Gdj(N5n(0G8pj8Tir95GPbdDXQ(CKGTZYgd0knYI8dKmKb9zaIFW6rRiocXKfbRZWRckgRb1X5So53zyOe8ah6uPZNgWDcJOwGpbRZp8qNkD(0WliQYBJ)b(eSo)qZqxSQphjy7SSXaTsBtWb4i3M1P1UaRhTI4ietweSodpWvbfJ1G64CwN87mmui0m0fR6Zrc2olBmqR02eCaoYTzDATlW6rR)ObYI8dKmKb9zaIFbehHyYIG1z4bUkD(0aUtye1c8jyD(HxfumwdQJZzDYVZWqjOzOlw1NJeSDw2yGwPTn(N1bH4tn0fR6Zrc2olBmqR0W97ZewqW6rReaCVNvbfJvsa3VptybbtdWAxe)wJdRFkJqTa014g6Iv95ibBNLngOvA4(95OUqnyTlIFRXH1pLrOwaA2XX53fLxJdRFkJqTa0ShTQULkcmRnapWTZ0)bYf2g)ZytxdTaGdo7m9FGCbC)(mwxiAOfa0m0fR6Zrc2olBmqR0ilYpqYqg0Nbi(zOBOlw1NJei(fRZRBJ)zg1cq95m0fR6Zrce)I1zGwP9cIQSqS8r85G1JwXAJIcBJ)rdcp8dKZqxSQphjq8lwNbAL224FgB6QHUyvFosG4xSod0knYI8dKmKb95NfDbwpAvfumwdQJZzDYVZuM6WbNDM(pqUazr(bsgYG(8ZIUeSlckgtwBao4aUDM(pqUazr(bsgYG(8ZIUeSlckgtwJdVDM(pqUazr(bsgYG(8ZIUeqmU4hHYXSFaxGEqZqxSQphjq8lwNbALgPfH47zuwNmU8htiW6rRyTrrHTX)ObHhiQyPcMvGhFxGWAJIcy9z(ElrdTaGg8QGIXAqDCoRt(DgMgASr4GtfumwdQJZzDYVZuMI31qxSQphjq8lwNbAL2liQYBJ)W6rRiX)mVXNgK)jb)GjEJg6Iv95ibIFX6mqR0W97X47zKHUyvFosG4xSod0knYI8dKmKb95NfDbwpAf6WAJIcBJ)rdcp0cao4aUDM(pqUazr(bsgYG(8ZIUeSlckgtwBaES2OOW24F0GWdevSur547cndDXQ(CKaXVyDgOvAKf5hizlsilW6rRiX)mVXNgK)jb)Gzx4rI)zEJpni)tcFlsuFok3qJg6Iv95ibIFX6mqR0W97ZyDHOW6rRBcYfSoh(rj5wag6Iv95ibIFX6mqR02g)Z6Gq8PW6rR)ObYI8dKmKb9zaIFbeJl(rGHsW)Jg2eCaoYTzDATlbeJl(rGHsg6Iv95ibIFX6mqR0ilYpqYqg0Nbi(bRhTI4ietweSodVkOySguhNZ6KFNHHsWdDQ05td4oHrulWNG15hEOtLoFA4fev5TX)aFcwNFdDXQ(CKaXVyDgOvABcoah52SoT2fy9OvehHyYIG1z4vbfJ1G64CwN87mmuiCWbCv68PbCNWiQf4tW68d)pAGSi)ajdzqFgG4xaXriMSiyDgAg6Iv95ibIFX6mqR0W97ZrDHAWAxe)wJdRFkJqTa0SJJZVlkVghw)ugHAbOzpAvDlveywBaEGBNP)dKlSn(NXMUgAbahC2z6)a5c4(9zSUq0qlaOzOlw1NJei(fRZaTsJSi)ajdzqFgG4xPLwfa]] )

    
end
