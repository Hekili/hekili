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


    spec:RegisterPack( "Shadow", 20180930.1823, [[da0oMaqiqQ6rkvQnbLAuGKofiLvPujXRaWSGIUfsH2Li)cPAyuQ6yIklJs4zuQ00qk6AkvSnKs6BiLyCGeohirToqImpKsDpLyFqHdQuj1cbOhQujCrLkjDsLkrwjL0ovQAOifSuqQ0tPQPkQAVs(RugmqhMyXG6XuzYQ6YO2ms(mLYOvsNwy1kvI61uIMTuDBOA3Q8BfdhqlhYZrmDsxxu2Us57Gy8GuX5PuX8Hs2pfx5Q8L)fLR9wyFoOWEOSDTpLdkSWIDSO8QDaYLhO4SuSXL)eCU8(v5hiLhOyN(iFLV8Kjd54YVQkqcuIoDBHUMbNCdoDsGN1fnMZHekLojWD0H7dmDykHgFEJoq0qfDMqNgqm0vINqNgGUnAafmrB(v5hijsG7kpCw01DPRGl)lkx7TW(CqH9qz7AFkhuyHf0CNYlz66GkVpW3fLFn(NVcU8ptCLF3gq)Q8dedinGcMOgR72aUQkqcuIoDBHUMbNCdoDsGN1fnMZHekLojWD0H7dmDykHgFEJoq0qfDMqNgqm0vINqNgGUnAafmrB(v5hijsG7mw3Tb0ZavghMrgq7ApMgqlSphuyaPrdyoAbkrt7nwnw3TbCxSkNnMaLmw3TbKgnG76)53a6JoFoozSUBdinAa3fZTXiLFdOkiBS2ckdiXoNkqNu57brjv(YtIZwNR81(Cv(YlonMR8Bt8ngLbuJ5kpFcCN)cWsR9wu5lpFcCN)cWY7qHYOqkpCgfvABINAq4PFGCLxCAmx5Fbzztio(iXCLw7TBLV8ItJ5k)2eFdE6A55tG78xawATNMv(YZNa35VaS8ouOmkKYRcYgRjnW5MoTpydiTnG21aIfwgq3m9FGCjYQ8dKgKb9TNfDn5wfKnMyaxmGwyaXcldiunGUz6)a5sKv5hinid6Bpl6AYTkiBmXaUyaZzaX2a6MP)dKlrwLFG0GmOV9SORjeJlXrmG02aAZ9jCb6yaHw5fNgZvEYQ8dKgKb9TNfDT0A)ov(YZNa35VaS8ouOmkKYdNrrL2M4PgeEIOIZsdiglgqOAaZTJbeadiCgfvcUpZ3ZiAkdObeAgqSnGQGSXAsdCUPt7d2aIHb0c7T3aIfwgqvq2ynPbo30P9bBaPTbKw2P8ItJ5kpjdH47zutNgU8htiLw7P1kF55tG78xawEhkugfs5rs8nEJpnj)tsXzaXWaMZ(YlonMR8VGSSTnXxATNwQ8LxCAmx5XJ7H57zu55tG78xawAThkQ8LNpbUZFby5DOqzuiLh6nGWzuuPTjEQbHNYaAaXcldiunGUz6)a5sKv5hinid6Bpl6AYTkiBmXaUyaTWaITbeoJIkTnXtni8erfNLgqABaZTJbeALxCAmx5jRYpqAqg03Ew01sR9q5kF55tG78xawEhkugfs5rs8nEJpnj)tsXzaXWaUJbeBdisIVXB8Pj5Fs6ZqIgZzaPTb0c7lV40yUYtwLFG0CiHSwATpN9v(YZNa35VaS8ouOmkKYVjOqG7C6hL0YawEXPXCLhpUVb3fIwATpxUkF55tG78xawEhkugfs5)rtKv5hinid6BaL4sigxIJyaXWastdi2gWF00MGdmqHRPtMBnHyCjoIbeddinlV40yUYVnX30bH4tlT2NZIkF55tG78xawEhkugfs5rmfIjRcCNnGyBavbzJ1Kg4CtN2hSbeddinnGyBaHEdOkD(0eEqyKDs8jWD(nGyBaHEdOkD(00lilBBt8j(e4o)LxCAmx5jRYpqAqg03akXvATpNDR8LNpbUZFby5DOqzuiLhXuiMSkWD2aITbufKnwtAGZnDAFWgqmmG0QbelSmGq1aQsNpnHhegzNeFcCNFdi2gWF0ezv(bsdYG(gqjUeIPqmzvG7SbeALxCAmx53eCGbkCnDYCRLw7ZrZkF55tG78xawEXPXCLhpUVr1f7u(4ugHYaQTGQ8A4SKGXIfydv3m9FGCPTj(g801ugqSWYnt)hixcpUVb3fIMYacTYhNYiugqTf448hIYLpx5DRsCLpxP1(C7u5lV40yUYtwLFG0GmOVbuIR88jWD(lalT0Y)mLK11kFTpxLV8ItJ5kpj6854YZNa35VaS0AVfv(YlonMR8zeUfkJtkpFcCN)cWsR92TYxE(e4o)fGL3HcLrHuE4mkQeCFMVNr0eIfNAaXcldOkiBSM0aNB60(GnG0EXacf2BaXcldOkiBSMwzPRRjGo1asBdOD3P8ItJ5kpWrJ5kT2tZkF55tG78xaw(by5jSwEXPXCLFtqHa35YVj9mU8)OjYQ8dKgKb9nGsCjnCwgNndi2gWF00MGdmqHRPtMBnPHZY4Sv(nb1obNl)pkPLbS0A)ov(YZNa35VaS8ouOmkKYdNrrL2M4PgeEkdy5fNgZvEQaXW9z(sR90ALV8ItJ5kpmJimYY4SvE(e4o)fGLw7PLkF5fNgZv(EyBvjTD5S3goFA55tG78xawAThkQ8LNpbUZFby5DOqzuiLhoJIkTnXtni8ugWYlonMR8Y5yIIKEZj9EP1EOCLV88jWD(lalVdfkJcP8eGCV3ubzJvscpUVrybzaXWacvd4ogqamG5mG7kgqv68Pj8GWi7K4tG78BaHw5fNgZvEu21eNgZ16brlFpiA7eCU8YWLw7ZzFLV88jWD(lalVdfkJcP8ItJnUXhJhmXaIHbmx5fNgZvEu21eNgZ16brlFpiA7eCU8UolBCP1(C5Q8LNpbUZFby5DOqzuiLxCASXn(y8GjgWfdyUYlonMR8OSRjonMR1dIw(Eq02j4C5jXzRZLwA5bIy3GdlALV2NRYxE(e4o)fGLw7TOYxE(e4o)fGLw7TBLV88jWD(lalT2tZkF55tG78xawATFNkF5fNgZvEGJgZvE(e4o)fGLw7P1kF55tG78xawEhkugfs5HEdiCgfvISk)aHAq4PmGLxCAmx5jRYpqOgeEP1EAPYxEXPXCLhpUVb3fIwE(e4o)fGLw7HIkF5fNgZvE84(gCxiA55tG78xawAPLxgUYx7Zv5lV40yUYVnX3yugqnMR88jWD(lalT2BrLV88jWD(lalVdfkJcP8WzuuPTjEQbHN(bYvEXPXCL)fKLnH44JeZvAT3Uv(YZNa35VaS8ouOmkKYRsNpn9cYY22eFIpbUZVbeBd4pAISk)aPbzqFdOexcX4sCediggqfjBCVPboxEXPXCLFBIVbpDT0ApnR8LNpbUZFby5DOqzuiLhoJIkTnXtni8erfNLgqmwmGq1aMBhdiagq4mkQeCFMVNr0ugqdi0kV40yUYtYqi(Eg10PHl)XesP1(DQ8LNpbUZFby5DOqzuiLhjX34n(0K8pjfNbeddyo7lV40yUY)cYY22eFP1EATYxEXPXCLhpUhMVNrLNpbUZFbyP1EAPYxE(e4o)fGL3HcLrHuEKeFJ34ttY)KuCgqmmG7yaX2aIK4B8gFAs(NK(mKOXCgqABaTW(YlonMR8Kv5hinhsiRLw7HIkF55tG78xawEXPXCLhpUVrybv(4ugHYaQTGQ8A4SKGXIfydv3m9FGCPTj(g801ugqSWYnt)hixcpUVb3fIMYacTYhNYiugqTf448hIYLpx5DRsCLpxP1EOCLV8ItJ5kpzv(bsdYG(gqjUYZNa35VaS0slVRZYgx5R95Q8LxCAmx53M4BmkdOgZvE(e4o)fGLw7TOYxE(e4o)fGL3HcLrHuE4mkQ02ep1GWt)a5kV40yUY)cYYMqC8rI5kT2B3kF5fNgZv(Tj(g801YZNa35VaS0ApnR8LNpbUZFby5DOqzuiLxfKnwtAGZnDAFWgqABaTRbelSmGWzuuPTjEQbHN(bYvEXPXCLNSk)aPbzqF7zrxlT2VtLV88jWD(lalVdfkJcP8WzuuPTjEQbHNiQ4S0aIXIbeQgWC7yabWacNrrLG7Z89mIMYaAaHw5fNgZvEsgcX3ZOMonC5pMqkT2tRv(YZNa35VaS8ouOmkKYJK4B8gFAs(NKIZaIHbmN9LxCAmx5FbzzBBIV0ApTu5lV40yUYJh3dZ3ZOYZNa35VaS0Apuu5lV40yUYJh33G7crlpFcCN)cWsR9q5kF55tG78xawEhkugfs5HQbejX34n(0K8pjfNbedd4ogqSnGij(gVXNMK)jPpdjAmNbK2gqlmGqZaIfwgqKeFJ34ttY)K0NHenMZaIHb0IYlonMR8Kv5hinhsiRLw7ZzFLV88jWD(lalVdfkJcP8iMcXKvbUZgqSnGQGSXAsdCUPt7d2aIHbKMgqSnGq1ac9gqv68Pj8GWi7K4tG78BaX2ac9gqv68PPxqw22M4t8jWD(nGqR8ItJ5kpzv(bsdYG(gqjUsR95Yv5lpFcCN)cWY7qHYOqkpIPqmzvG7SbeBdiunGQGSXAsdCUPt7d2aIHbKwnGqR8ItJ5k)MGdmqHRPtMBT0AFolQ8LNpbUZFby5DOqzuiL)hnrwLFG0GmOVbuIlHyketwf4oBaX2acvdOkD(0eEqyKDs8jWD(nGyBavbzJ1Kg4CtN2hSbeddinnGqR8ItJ5k)MGdmqHRPtMBT0AFo7w5lV40yUYVnX30bH4tlpFcCN)cWsR95OzLV88jWD(lalV40yUYJh33iSGkFCkJqza1YNR8ouOmkKYtaY9EtfKnwjj84(gHfKbeddOfL3TkXv(CLw7ZTtLV88jWD(lalV40yUYJh33O6IDkFCkJqza1wqvEnCwsWyXcSHQBM(pqU02eFdE6Akdiwy5MP)dKlHh33G7crtzaHw5JtzekdO2cCC(dr5YNR8UvjUYNR0AFoATYxEXPXCLNSk)aPbzqFdOex55tG78xawAPLw(ngrI5Q9wyFoOWEOSDTpLJwO5oLhIGU4Srk)UeoWbP8Ba3XakonMZa2dIssgRLhiAOIox(DBa9RYpqmG0akyIASUBd4QQajqj60Tf6AgCYn40jbEwx0yohsOu6Ka3rhUpW0HPeA85n6ardv0zcDAaXqxjEcDAa62ObuWeT5xLFGKibUZyD3gqpduzCygzaTR9yAaTW(CqHbKgnG5OfOenT3y1yD3gWDXQC2ycuYyD3gqA0aUR)NFdOp6854KX6UnG0ObCxm3gJu(nGQGSXAlOmGe7CQaDsgRgR72aURcDyxMYVbeMPgeBaDdoSOgqy2wCKKbCx7CmqLyaV5OXvbHtL1nGItJ5igW562jzSkonMJKaIy3Gdl6cvxiwASkonMJKaIy3Gdlkal0PM5nwfNgZrsarSBWHffGf6sMnC(urJ5mw3Tb0FcqY6OgqKeVbeoJIIFdirfLyaHzQbXgq3GdlQbeMTfhXak3BabIyAe4OAC2mGbXa(ZXjJvXPXCKeqe7gCyrbyHo5eGK1rBevuIXQ40yosciIDdoSOaSqh4OXCgRItJ5ijGi2n4WIcWcDYQ8deQbHJzqTa9WzuujYQ8deQbHNYaASkonMJKaIy3Gdlkal0XJ7BWDHOgRItJ5ijGi2n4WIcWcDYQ8dKgKb9TTjEJvJ1DBa3vHoSlt53aYBmYogqnWzdOUYgqXPdYagedOSjrxG7CYyvCAmhzHeD(CSXQ40yocal0ZiClugNySkonMJaWcDGJgZHzqTaNrrLG7Z89mIMqS4uSWsfKnwtAGZnDAFW0EbkShlSubzJ10klDDnb0P02U7ySkonMJaWc9nbfcCNX8eCE5hL0YaI5aCHWkMBspJx(rtKv5hinid6BaL4sA4SmoBy)JM2eCGbkCnDYCRjnCwgNnJvXPXCeawOtfigUpZJzqTaNrrL2M4PgeEkdOXQ40yocal0HzeHrwgNnJvXPXCeawO3dBRkPTlN92W5tnwfNgZrayHUCoMOiP3CsVJzqTaNrrL2M4PgeEkdOXQ40yocal0rzxtCAmxRhefZtW5fzymdQfcqU3BQGSXkjHh33iSGWaQ7aqUDfv68Pj8GWi7K4tG78dnJvXPXCeawOJYUM40yUwpikMNGZlUolBmMb1I40yJB8X4btWiNXQ40yocal0rzxtCAmxRhefZtW5fsC26mMb1I40yJB8X4btwYzSASkonMJKKHx2M4BmkdOgZzSkonMJKKHbyH(lilBcXXhjMdZGAboJIkTnXtni80pqoJvXPXCKKmmal03M4BWtxXmOwuPZNMEbzzBBIpXNa35h7F0ezv(bsdYG(gqjUeIXL4iyOizJ7nnWzJvXPXCKKmmal0jzieFpJA60WL)ycbZGAboJIkTnXtni8erfNLySa1C7aaCgfvcUpZ3ZiAkdi0mwfNgZrsYWaSq)fKLTTjEmdQfKeFJ34ttY)KuCyKZEJvXPXCKKmmal0XJ7H57zKXQ40yossggGf6Kv5hinhsiRygulij(gVXNMK)jP4WyhSrs8nEJpnj)tsFgs0yoABH9gRItJ5ijzyawOJh33iSGW0TkXTKdZ4ugHYaQTahN)quEjhMXPmcLbuBb1IgoljySyb2q1nt)hixABIVbpDnLbelSCZ0)bYLWJ7BWDHOPmGqZyvCAmhjjddWcDYQ8dKgKb9nGsCgRgRItJ5ijxNLnEzBIVXOmGAmNXQ40yosY1zzJbyH(lilBcXXhjMdZGAboJIkTnXtni80pqoJvXPXCKKRZYgdWc9Tj(g80vJvXPXCKKRZYgdWcDYQ8dKgKb9TNfDfZGArfKnwtAGZnDAFW02UyHfCgfvABINAq4PFGCgRItJ5ijxNLngGf6KmeIVNrnDA4YFmHGzqTaNrrL2M4PgeEIOIZsmwGAUDaaoJIkb3N57zenLbeAgRItJ5ijxNLngGf6VGSSTnXJzqTGK4B8gFAs(NKIdJC2BSkonMJKCDw2yawOJh3dZ3ZiJvXPXCKKRZYgdWcD84(gCxiQXQ40yosY1zzJbyHozv(bsZHeYkMb1curs8nEJpnj)tsXHXoyJK4B8gFAs(NK(mKOXC02cOHfwij(gVXNMK)jPpdjAmhgwySkonMJKCDw2yawOtwLFG0GmOVbuIdZGAbXuiMSkWDgBvq2ynPbo30P9bJbnXgQqVkD(0eEqyKDs8jWD(Xg6vPZNMEbzzBBIpXNa35hAgRItJ5ijxNLngGf6BcoWafUMozUvmdQfetHyYQa3zSHQkiBSM0aNB60(GXGwHMXQ40yosY1zzJbyH(MGdmqHRPtMBfZGA5hnrwLFG0GmOVbuIlHyketwf4oJnuvPZNMWdcJStIpbUZp2QGSXAsdCUPt7dgdAcnJvXPXCKKRZYgdWc9Tj(MoieFQXQ40yosY1zzJbyHoECFJWccZGAHaK79MkiBSss4X9nclimSat3Qe3somJtzekdOUKZyvCAmhj56SSXaSqhpUVr1f7GPBvIBjhMXPmcLbuBboo)HO8somJtzekdO2cQfnCwsWyXcSHQBM(pqU02eFdE6Akdiwy5MP)dKlHh33G7crtzaHMXQ40yosY1zzJbyHozv(bsdYG(gqjoJvJvXPXCKejoBDEzBIVXOmGAmNXQ40yosIeNTodWc9xqw2eIJpsmhMb1cCgfvABINAq4PFGCgRItJ5ijsC26mal03M4BWtxnwfNgZrsK4S1zawOtwLFG0GmOV9SORygulQGSXAsdCUPt7dM22flSCZ0)bYLiRYpqAqg03Ew01KBvq2yYIfyHfuDZ0)bYLiRYpqAqg03Ew01KBvq2yYsoSDZ0)bYLiRYpqAqg03Ew01eIXL4i02M7t4c0bAgRItJ5ijsC26mal0jzieFpJA60WL)ycbZGAboJIkTnXtni8erfNLySa1C7aaCgfvcUpZ3ZiAkdi0WwfKnwtAGZnDAFWyyH92JfwQGSXAsdCUPt7dM20YogRItJ5ijsC26mal0FbzzBBIhZGAbjX34n(0K8pjfhg5S3yvCAmhjrIZwNbyHoECpmFpJmwfNgZrsK4S1zawOtwLFG0GmOV9SORygulqpCgfvABINAq4PmGyHfuDZ0)bYLiRYpqAqg03Ew01KBvq2yYIfydNrrL2M4PgeEIOIZsANBhOzSkonMJKiXzRZaSqNSk)aP5qczfZGAbjX34n(0K8pjfhg7GnsIVXB8Pj5Fs6ZqIgZrBlS3yvCAmhjrIZwNbyHoECFdUlefZGAztqHa350pkPLb0yvCAmhjrIZwNbyH(2eFtheIpfZGA5hnrwLFG0GmOVbuIlHyCjocg0e7F00MGdmqHRPtMBnHyCjocg00yvCAmhjrIZwNbyHozv(bsdYG(gqjomdQfetHyYQa3zSvbzJ1Kg4CtN2hmg0eBOxLoFAcpimYoj(e4o)yd9Q05ttVGSSTnXN4tG78BSkonMJKiXzRZaSqFtWbgOW10jZTIzqTGyketwf4oJTkiBSM0aNB60(GXGwXclOQsNpnHhegzNeFcCNFS)rtKv5hinid6BaL4siMcXKvbUZqZyvCAmhjrIZwNbyHoECFJQl2bt3Qe3somJtzekdO2cCC(dr5LCygNYiugqTfulA4SKGXIfydv3m9FGCPTj(g801ugqSWYnt)hixcpUVb3fIMYacnJvXPXCKejoBDgGf6Kv5hinid6BaL4kpbi7Q9wSduuAPvb]] )

    
end
