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
    
        package = "Shadow",
    } )


    spec:RegisterPack( "Shadow", 20180813.0858, [[dOeYLaqiqsTiHQipsOQ0Mav(Kqv1Oav1PavzvcvHEfimlqQBbvs2LGFPQ0WajoMqSmHuptOIPjK4AQkSnHK6BcjzCcv6CGKuRdQenpOsDpL0(afheKeTqq0dfQkMiujfxuOkvFeQKkJeQKsNeKewPqzMcvjDtHQG2Ps0qfQIAPcvP8urnvLWwfQs8vqsYEv8xrgSuomPfdLht0Kv5YO2mH(mu1OLkNMQvdvsvVgQy2k1Tjy3a)wYWvvDCHQalhYZrmDkxxQA7QIVRknEOs48QkA(Gs7hPNiZIjFQXZYOHsK4cL4gjobOe3pIBCIQjBF(Zt(xL4O45jdubEY5o9Q3j)RFUl9MftMu9ijp5oZ(j4YVFX7wxpwqwcFjUq)wnVasKkAFjUG8l2UW(IjQ4QJF((JkrFZKVlCgfDKVlIoskEg5mXs5o9Q3aXfKtgR33gubyWM8PgplJgkrIluIBK4eGsC)ikXjUtw7TUcn5SleFM8Xe5Kx05eAZj0MsB)QehfptBLiTPsZlaTTDIrOnXcrB4AzC8ThOXOXw8YkoeCjTrB4ACrrgXaZvJpAldvfVqBIOsG2Ih6GJ2GCReJ2Wv4kAZ6yAl7cXhAdQmEoEL2UIjG43Onhi39htBiwwccm4uZlaH2eleTL70REPnOQcD4sAlEP8J2W4plWrBwhtB1pdyuGgJglEJfQh(OThf5k2MdxzKu)pT5aAtuFkeTvI0MSJL44a802vwG0Px9MEl0L(vhemxIJdWtBk4OTRSWJk87ixMSQx2fmxIJdWdnTzfT1X7FAZ6yAtVRaXpH2mxWb4PngG3bmT9J4ZLgTPy(2TpPTEIINPnm2mgfOXOXIpf4HrgF0w8KPi8SLCX4jAJ8jWuCbTzfTj)uU5KPi8SrOnfC0ME467jgF0MSaNBEbi02BhJyAdW8XhTjwiAtOFB(vM5a8HjVDIrMftM4a8BEwmlJmlMSknVat(P8lXO(FZlWKzGIT5BGCSzz0ZIjZafBZ3a5KLi3yKRtgRxum8u(jwiHWvVGjRsZlWKpfHtsjsgq8cm2SmoZIjRsZlWKFk)sy12MmduSnFdKJnlJYSyYmqX28nqozjYng56KnfHNTG5cCYQ05mTHBAlo0gSWsBYQ2x9ccKo9Q30BHU0XQ1fKDkcptOTvAlAAdwyPn4tBYQ2x9ccKo9Q30BHU0XQ1fKDkcptOTvAlcTbhTjRAF1liq60REtVf6shRwxaXcQdi0gUPn8YJ2G3KvP5fyYKo9Q30BHU0XQ1n2S8JzXKzGIT5BGCYsKBmY1jJ1lkgEk)elKqGyQehAdMvAd(0wKpOniOnSErXa2UQB3tSq)pTbpAdoAZueE2cMlWjRsNZ0gm0w0qbk0gSWsBMIWZwWCbozv6CM2WnTfvFmzvAEbMmPhHyWXOKvjb9amHm2SmQNftMbk2MVbYjlrUXixNms9lXpmWc6DKGdOnyOTiqzYQ08cm5tr4KEk)gBwgvZIjRsZlWKfCWHXGJrtMbk2MVbYXMLXDwmzgOyB(giNSe5gJCDYqnTH1lkgEk)elKqO)N2GfwAd(0MSQ9vVGaPtV6n9wOlDSADbzNIWZeABL2IM2GJ2W6ffdpLFIfsiqmvIdTHBAlYh0g8MSknVatM0Px9MEl0LowTUXMLq1ZIjZafBZ3a5KLi3yKRtgP(L4hgyb9osWb0gm02h0gC0gs9lXpmWc6DKW1JuZlaTHBAlAOmzvAEbMmPtV6njrkPBSzzeOmlMmduSnFdKtwICJrUo5RSaPtV6n9wOl9RoiyUehhGN2GJ2UYcpQWVJCzYQEzxWCjooa)KvP5fyYco4syBLyJnlJezwmzgOyB(giNSe5gJCDYxzbsNE1B6Tqx6xDqaXcQdi0gm0wuOn4OTRSWJk87ixMSQx2fqSG6acTbdTfLjRsZlWKFk)swHqmWgBwgj6zXKzGIT5BGCYsKBmY1jJyret6uSntBWrBMIWZwWCbozv6CM2GH2IcTbhTb10MPBgybbNWOpdmqX28rBWrBqnTz6Mbw4ueoPNYVaduSnFtwLMxGjt60REtVf6s)QdgBwgjoZIjZafBZ3a5KLi3yKRtgXIiM0PyBM2GJ2mfHNTG5cCYQ05mTbdTf10gSWsBWN2mDZali4eg9zGbk2MpAdoA7klq60REtVf6s)QdciweXKofBZ0g8MSknVat(rf(DKltw1l7gBwgjkZIjZafBZ3a5KvP5fyYco4sIB9Zj7aJrO(Fl5It2CjoeywJgo4lRAF1li8u(LWQTf6)Hfwzv7REbbbhCjSTsSq)p8MSdmgH6)TKliWNRgp5itw2PoyYrgBwg5JzXKvP5fyYKo9Q30BHU0V6GjZafBZ3a5yJn5Jf1(TnlMLrMftwLMxGjt8ndK8KzGIT5BGCSzz0ZIjZafBZ3a5KLi3yKRtgRxumGTR629elGyvA0gSWsBMIWZwWCbozv6CM2W9kTfxOqBWclTzkcpBHow3wx4xA0gUPT48XKvP5fyY)L5fySzzCMftMbk2MVbYjlrUXixNm5N37KPi8Srcco4sewr0gm0g8PTpOniOTi0w8iTz6MbwqWjm6ZaduSnF0g8MSknVatg1dsQ08cK2oXM82jwcOc8K1IhBwgLzXKzGIT5BGCYsKBmY1jRsZF4edybNj0gm0wKjRsZlWKr9GKknVaPTtSjVDILaQapz5M1hESz5hZIjZafBZ3a5KLi3yKRtwLM)WjgWcotOTvAlYKvP5fyYOEqsLMxG02j2K3oXsavGNmXb438yJn5Fellbm1MfZYiZIjZafBZ3a5yZYONftMbk2MVbYXMLXzwmzgOyB(gihBwgLzXKzGIT5BGCSz5hZIjRsZlWK)lZlWKzGIT5BGCSzzuplMmduSnFdKtwICJrUozOM2W6ffdKo9QxXcje6)NSknVatM0Px9kwiHXMLr1SyYQ08cmzbhCjSTsSjZafBZ3a5yZY4olMSknVatM0Px9MEl0LEk)MmduSnFdKJn2K1INfZYiZIjRsZlWKFk)smQ)38cmzgOyB(gihBwg9SyYmqX28nqozjYng56KX6ffdpLFIfsiC1lyYQ08cm5tr4KuIKbeVaJnlJZSyYmqX28nqozjYng56KnDZalCkcN0t5xGbk2MpAdoA7klq60REtVf6s)QdciwqDaH2GH2mK(W7K5c8KvP5fyYpLFjSABJnlJYSyYmqX28nqozjYng56KX6ffdpLFIfsiqmvIdTbZkTbFAlYh0ge0gwVOyaBx1T7jwO)N2G3KvP5fyYKEeIbhJswLe0dWeYyZYpMftMbk2MVbYjlrUXixNms9lXpmWc6DKGdOnyOTiqzYQ08cm5tr4KEk)gBwg1ZIjRsZlWKfCWHXGJrtMbk2MVbYXMLr1SyYmqX28nqozjYng56KrQFj(HbwqVJeCaTbdT9bTbhTHu)s8ddSGEhjC9i18cqB4M2IgktwLMxGjt60REtsKs6gBwg3zXKzGIT5BGCYQ08cmzbhCjcROj7aJrO(Fl5It2CjoeywJgo4lRAF1li8u(LWQTf6)Hfwzv7REbbbhCjSTsSq)p8MSdmgH6)TKliWNRgp5itw2PoyYrgBwcvplMSknVatM0Px9MEl0L(vhmzgOyB(gihBSjl3S(WZIzzKzXKvP5fyYpLFjg1)BEbMmduSnFdKJnlJEwmzgOyB(giNSe5gJCDYy9IIHNYpXcjeU6fmzvAEbM8PiCskrYaIxGXMLXzwmzvAEbM8t5xcR22KzGIT5BGCSzzuMftMbk2MVbYjlrUXixNSPi8SfmxGtwLoNPnCtBXH2GfwAdRxum8u(jwiHWvVGjRsZlWKjD6vVP3cDPJvRBSz5hZIjZafBZ3a5KLi3yKRtgRxum8u(jwiHaXujo0gmR0g8PTiFqBqqBy9IIbSDv3UNyH(FAdEtwLMxGjt6rigCmkzvsqpatiJnlJ6zXKzGIT5BGCYsKBmY1jJu)s8ddSGEhj4aAdgAlcuMSknVat(ueoPNYVXMLr1SyYQ08cmzbhCym4y0KzGIT5BGCSzzCNftwLMxGjl4GlHTvInzgOyB(gihBwcvplMSknVatM0Px9MEl0LEk)MmduSnFdKJnlJaLzXKzGIT5BGCYsKBmY1jdFAdP(L4hgyb9osWb0gm02h0gC0gs9lXpmWc6DKW1JuZlaTHBAlAAdE0gSWsBi1Ve)WalO3rcxpsnVa0gm0w0twLMxGjt60REtsKs6gBwgjYSyYmqX28nqozvAEbMmPtV6n9wOl9RoyYsKBmY1jJyret6uSntBWrBMIWZwWCbozv6CM2GH2IcTbhTb10MPBgybbNWOpdmqX28rBWrBqnTz6Mbw4ueoPNYVaduSnFtw(PCZjtr4zJmlJm2Sms0ZIjZafBZ3a5KvP5fyYpQWVJCzYQEz3KLi3yKRtgXIiM0PyBM2GJ2mfHNTG5cCYQ05mTbdTf1tw(PCZjtr4zJmlJm2SmsCMftMbk2MVbYjRsZlWKFuHFh5YKv9YUjlrUXixN8vwG0Px9MEl0L(vheqSiIjDk2MPn4Ont3mWccoHrFgyGIT5J2GJ2mfHNTG5cCYQ05mTbdTfLjl)uU5KPi8SzKjhzSzzKOmlMSknVat(P8lzfcXaBYmqX28nqo2SmYhZIjZafBZ3a5KvP5fyYco4sewrt2bgJq9)2KJmzjYng56Kj)8ENmfHNnsqWbxIWkI2GH2IEYYo1btoYyZYir9SyYmqX28nqozvAEbMSGdUK4w)CYoWyeQ)3sU4KnxIdbM1OHd(YQ2x9ccpLFjSABH(FyHvw1(QxqqWbxcBRel0)dVj7aJrO(Fl5cc85QXtoYKLDQdMCKXMLrIQzXKvP5fyYKo9Q30BHU0V6GjZafBZ3a5yJn2KFyeXlWSmAOejUqjUqjQcrhNOJm5xfbCaEYKHQGkJ3wcvSexhUK2OTfDmT5c)fYOnXcrBXpXb43C8tBioEqVJ4J2iLatBAVvcQXhTj7uaEMeOXIxDatBrbxsBXNc8WiJpAl(XlVGGIlIFAZkAl(XlV4N2GFeCb8c0y0yqfc)fY4J2(G2uP5fG22oXibASjt(z5Sm6pI7K)rLOV5jhFPT4DCbl7n(OnmwSqmTjlbm1OnmgVdibAdQuk5FJqBGcGR6uKGy)M2uP5fGqBfy)zGgtLMxas4hXYsatTvXTsWHgtLMxas4hXYsatniw)kw1rJPsZlaj8JyzjGPgeRF1E8cmWuZlanw8L2Ya9N0vgTHu)OnSErr(OnIPgH2WyXcX0MSeWuJ2Wy8oGqBk4OTFeJR(lZCaEAZj02vaoqJPsZlaj8JyzjGPgeRFja9N0vwIyQrOXuP5fGe(rSSeWudI1V)L5fGgtLMxas4hXYsatniw)s60REflKa0U4kuJ1lkgiD6vVIfsi0)tJPsZlaj8JyzjGPgeRFfCWLW2kXOXuP5fGe(rSSeWudI1VKo9Q30BHU0t5hngnw8L2I3XfSS34J24hg9jTzUatBwhtBQ0keT5eAtFuFRyBoqJPsZlazL4BgizAmvAEbiqS(9VmVaq7IRy9IIbSDv3UNybeRsdwynfHNTG5cCYQ05mUxJluGfwtr4zl0X626c)sd3X5dAS4lTPsZlabI1VpkYvSndnqf41RmsQ)h66FLWg0p6UNxVYcKo9Q30BHU0V6GG5sCCaE4UYcpQWVJCzYQEzxWCjooapnMknVaeiw)I6bjvAEbsBNyqdubEvlgAxCL8Z7DYueE2ibbhCjcRiyG)hqejE00ndSGGty0NbgOyB(GhnMknVaeiw)I6bjvAEbsBNyqdubEvUz9HH2fxvP5pCIbSGZeyIqJPsZlabI1VOEqsLMxG02jg0avGxjoa)MH2fxvP5pCIbSGZK1i0y0yQ08cqcAXRpLFjg1)BEbOXuP5fGe0IHy97PiCskrYaIxaODXvSErXWt5NyHecx9cOXuP5fGe0IHy97t5xcR2g0U4QPBgyHtr4KEk)cmqX28b3vwG0Px9MEl0L(vheqSG6acmgsF4DYCbMgtLMxasqlgI1VKEeIbhJswLe0dWec0U4kwVOy4P8tSqcbIPsCGzf(r(acSErXa2UQB3tSq)p8OXuP5fGe0IHy97PiCspLFq7IRi1Ve)WalO3rcoaMiqHgtLMxasqlgI1Vco4WyWXiAmvAEbibTyiw)s60REtsKs6G2fxrQFj(HbwqVJeCamFahs9lXpmWc6DKW1JuZlaUJgk0yQ08cqcAXqS(vWbxIWkcAzN6G1iq7aJrO(Fl5cc85QXRrG2bgJq9)wYfxnxIdbM1OHd(YQ2x9ccpLFjSABH(FyHvw1(QxqqWbxcBRel0)dpAmvAEbibTyiw)s60REtVf6s)QdOXOXuP5fGeKBwF41NYVeJ6)nVa0yQ08cqcYnRpmeRFpfHtsjsgq8caTlUI1lkgEk)elKq4QxanMknVaKGCZ6ddX63NYVewTnAmvAEbib5M1hgI1VKo9Q30BHU0XQ1bTlUAkcpBbZf4KvPZzChhyHfRxum8u(jwiHWvVaAmvAEbib5M1hgI1VKEeIbhJswLe0dWec0U4kwVOy4P8tSqcbIPsCGzf(r(acSErXa2UQB3tSq)p8OXuP5fGeKBwFyiw)EkcN0t5h0U4ks9lXpmWc6DKGdGjcuOXuP5fGeKBwFyiw)k4GdJbhJOXuP5fGeKBwFyiw)k4GlHTvIrJPsZlaji3S(WqS(L0Px9MEl0LEk)OXuP5fGeKBwFyiw)s60REtsKs6G2fxHps9lXpmWc6DKGdG5d4qQFj(HbwqVJeUEKAEbWD0WdwyrQFj(HbwqVJeUEKAEbGjAAmvAEbib5M1hgI1VKo9Q30BHU0V6aOLFk3CYueE2iRrG2fxrSiIjDk2MHZueE2cMlWjRsNZWef4GAt3mWccoHrFgyGIT5doO20ndSWPiCspLFbgOyB(OXuP5fGeKBwFyiw)(Oc)oYLjR6LDql)uU5KPi8SrwJaTlUIyret6uSndNPi8SfmxGtwLoNHjQPXuP5fGeKBwFyiw)(Oc)oYLjR6LDql)uU5KPi8SzK1iq7IRxzbsNE1B6Tqx6xDqaXIiM0PyBgot3mWccoHrFgyGIT5dotr4zlyUaNSkDodtuOXuP5fGeKBwFyiw)(u(LScHyGrJPsZlaji3S(WqS(vWbxIWkcAxCL8Z7DYueE2ibbhCjcRiyIgAzN6G1iq7aJrO(FBncnMknVaKGCZ6ddX6xbhCjXT(j0Yo1bRrG2bgJq9)wYfe4ZvJxJaTdmgH6)TKlUAUehcmRrdh8LvTV6feEk)sy12c9)WcRSQ9vVGGGdUe2wjwO)hE0yQ08cqcYnRpmeRFjD6vVP3cDPF1b0y0yQ08cqcehGFZRpLFjg1)BEbOXuP5fGeioa)MHy97PiCskrYaIxaODXvSErXWt5NyHecx9cOXuP5fGeioa)MHy97t5xcR2gnMknVaKaXb43meRFjD6vVP3cDPJvRdAxC1ueE2cMlWjRsNZ4ooWcRSQ9vVGaPtV6n9wOlDSADbzNIWZK1OHfw4lRAF1liq60REtVf6shRwxq2Pi8mzncCYQ2x9ccKo9Q30BHU0XQ1fqSG6acUXlVGGIlGhnMknVaKaXb43meRFj9iedogLSkjOhGjeODXvSErXWt5NyHecetL4aZk8J8bey9IIbSDv3UNyH(F4bNPi8SfmxGtwLoNHjAOafyH1ueE2cMlWjRsNZ4oQ(GgtLMxasG4a8BgI1VNIWj9u(bTlUIu)s8ddSGEhj4ayIafAmvAEbibIdWVziw)k4GdJbhJOXuP5fGeioa)MHy9lPtV6n9wOlDSADq7IRqnwVOy4P8tSqcH(FyHf(YQ2x9ccKo9Q30BHU0XQ1fKDkcptwJgoSErXWt5NyHecetL4G7iFapAmvAEbibIdWVziw)s60REtsKs6G2fxrQFj(HbwqVJeCamFahs9lXpmWc6DKW1JuZlaUJgk0yQ08cqcehGFZqS(vWbxcBRedAxC9klq60REtVf6s)QdcMlXXb4H7kl8Oc)oYLjR6LDbZL44a80yQ08cqcehGFZqS(9P8lzfcXadAxC9klq60REtVf6s)QdciwqDabMOa3vw4rf(DKltw1l7ciwqDabMOqJPsZlajqCa(ndX6xsNE1B6Tqx6xDa0U4kIfrmPtX2mCMIWZwWCbozv6CgMOahuB6MbwqWjm6ZaduSnFWb1MUzGfofHt6P8lWafBZhnMknVaKaXb43meRFFuHFh5YKv9YoODXvelIysNITz4mfHNTG5cCYQ05mmrnSWcFt3mWccoHrFgyGIT5dURSaPtV6n9wOl9RoiGyret6uSndpAmvAEbibIdWVziw)k4GljU1pHw2Poync0oWyeQ)3sUGaFUA8AeODGXiu)VLCXvZL4qGznA4GVSQ9vVGWt5xcR2wO)hwyLvTV6feeCWLW2kXc9)WJgtLMxasG4a8BgI1VKo9Q30BHU0V6GXgBga]] )

    
end
