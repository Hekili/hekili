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
        

        mind_blast = {
            id = 8092,
            cast = function () return haste * ( buff.shadowy_insight.up and 0 or 1.5 ) end,
            charges = function () return ( level < 116 and equipped.mangazas_madness ) and 2 or 1 end,
            cooldown = 7.5,
            recharge = 7.5,
            hasteCD = true,
            gcd = "spell",

            velocity = 15,

            spend = function () return ( talent.fortress_of_the_mind.enabled and 1.2 or 1 ) * ( -12 - buff.empty_mind.stack ) * ( buff.surrender_to_madness.up and 2 or 1 ) * ( debuff.surrendered_to_madness.up and 0 or 1 ) end,
            spendType = "insanity",
            
            startsCombat = true,
            texture = 136224,

            notalent = "shadow_word_void",
            
            handler = function ()
                removeBuff( "shadowy_insight" )
                removeBuff( "empty_mind" )
            end,
        },
        

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


    spec:RegisterPack( "Shadow", 20180807.2321, [[dGeoOaqiLs8iqIytGuFsPKAuqLofvWQukj6vGOzbkDlQOIDH0VaHHbs6ykHLrf6zGeMgvextPuBdQiFJkQACqfCoOcL1bvunpQiDpLQ9bQCqqIYcbfpeQqAIGePUOsjHpsfvIrcvOYjHkeRujAMurL6MurL0obQgQsjPwkirYtvyQkfBvPKKVcsuTxv(lPgmGdtSyO8yjMSuxg1MPsFgQA0sYPfEnOQzROBts7wv)w0WbYXHku1YH8CetNY1vsBxs9DsmEOIY5PIY8bk7NQ(wCBUrlgFG7iuxGdqfhGQZtDekCCHt2(gMZaX3aKuGxWZ34fv(gJkPtLBasC2mL(2CdsUIk8nQmdebNdbe4dRAfJwsviiH66uSi)csCniiHAbcSzIbbMR4CAUgcqO0nMmbInbJCCbeBCCHERgfmX0JkPtfkjul3aBnMgoYFy3OfJpWDeQlWbOIdq15PoUWjq1XBiRwvIUXiuXrVrZKYn2ufepqq8aIhaKuGxWZEG01diflY3dmdIr8aUjYdGJJHpMb1V0VCJclWtW5Eapau6W1Lr8BHyC7bgq5BvEaxuQ6bCUgF7bGzkeZd4CCoEaRI9aJqfh1daLTv7C7b6Kj)wBEG4lZ1M9aiUKQQ83If5t8aUjYdmQKov8aq5jQX5EGTQmApag7S8BpGvXEGee)mI6x6xcLIvZAU9a1ckeSjt70i6vqEG49aUsDI8aPRhOuXf4JhVhOtJsQKov0kjQ1GK4PwuGpE8Ea5BpqNgTwubfOOOTCTurTOaF84H1dyPhOING8awf7bKUZFRjEaluJhVhGF8XZEaqiUJI5beSygMZ8aRebp7bWyZye9gZGyKBZniXJFY3Md8f3MBiflY)g1z0AgTcYI8Vb)c2K7dMZoWD82Cd(fSj3hm3OGcJrHCdSvxxADgTBIuPDQ83qkwK)nAbbVwif(jr(NDGdf3MBiflY)g1z0ASCA3GFbBY9bZzh4o52Cd(fSj3hm3OGcJrHCdtq4zJAHkRTu3b7bCQhak8aGbMhOK5StLNsQKov0kjQ1nlwfTuji8mXdS7bC0dagyEaC9aLmNDQ8usL0PIwjrTUzXQOLkbHNjEGDpWcpa0EGsMZovEkPs6urRKOw3SyvueRkXt8ao1dGV0EahUHuSi)BqQKov0kjQ1nlw1zh4BFBUb)c2K7dMBuqHXOqUb2QRlToJ2nrQuIjf49aWT7bW1dSyBpaKEaSvxxk2mZEUsm6kipGdEaO9aMGWZg1cvwBPUd2daNhWrOcvpayG5bmbHNnQfQS2sDhShWPEaNF7BiflY)gKveI)MrAl1Qs)mHC2booDBUb)c2K7dMBuqHXOqUbsIwZ18BuPBcnEpaCEGfq9gsXI8Vrli411z0NDG783MBiflY)gQX3y83m6g8lytUpyo7ahhUn3GFbBY9bZnkOWyui3ylEaSvxxADgTBIuPRG8aGbMhaxpqjZzNkpLujDQOvsuRBwSkAPsq4zIhy3d4OhaApa2QRlToJ2nrQuIjf49ao1dSyBpGd3qkwK)nivsNkALe16MfR6SdCCSBZn4xWMCFWCJckmgfYnqs0AUMFJkDtOX7bGZdSThaApasIwZ18BuPBcTxrIf57bCQhWrOEdPyr(3GujDQOliHuD2b(cOEBUb)c2K7dMBuqHXOqUrNgLujDQOvsuRbjXtTOaF849aq7b60O1IkOaffTLRLkQff4Jh)nKIf5Fd14Bn2ui2zh4lwCBUb)c2K7dMBuqHXOqUrNgLujDQOvsuRbjXtTOaF849aq7b60O1IkOaffTLRLkQff4Jh)nKIf5FdsL0PIwjrTUoJ(Sd8foEBUb)c2K7dMBuqHXOqUrNgLujDQOvsuRbjXtrSQepXdaNhWjEaO9aDA0ArfuGII2Y1sffXQs8epaCEaNCdPyr(3OoJwBjcXVD2b(cO42Cd(fSj3hm3OGcJrHCde7IysLGnzpa0Eatq4zJAHkRTu3b7bGZd4epa0EGT4bmzYVrvdcJCgLFbBYThaApWw8aMm53OTGGxxNrt5xWMCFdPyr(3GujDQOvsuRbjXF2b(cNCBUb)c2K7dMBuqHXOqUbIDrmPsWMShaApGji8SrTqL1wQ7G9aW5bWjpayG5bW1dyYKFJQgeg5mk)c2KBpa0EGonkPs6urRKOwdsINIyxetQeSj7bC4gsXI8VrTOckqrrB5AP6Sd8fBFBUb)c2K7dMBiflY)gQX3A3P4SBeVXi0kithU3WIc8e42DeAClzo7u5P1z0ASCA0vqGbgU4AYKFJsQKov0kjQ11z0u(fSj3qxYC2PYtjvsNkALe166mA6kihadmC3Ijt(nkPs6urRKOwxNrt5xWMCdDjZzNkpvn(wJnfIrxb5GdoCJ4ngHwbz6qvL7qm(glUrPsI)glo7aFboDBUHuSi)BqQKov0kjQ1GK4Vb)c2K7dMZo7gn7kRt72CGV42Cd(fSj3hm3OGcJrHCdSvxxk2mZEUsmkILI5badmpGji8SrTqL1wQ7G9aoD3dGdq1dagyEatq4zJwXY0QOGkMhWPEaOy7BiflY)gGslY)SdChVn3GFbBY9bZnKIf5Fd06RLIf5RNbXUrbfgJc5geq8CQnbHNncvn(wtyb5bGZdGRhyBpaKEGfEGTspGjt(nQAqyKZO8lytU9aoCJzqm9lQ8nKKp7ahkUn3GFbBY9bZnKIf5Fd06RLIf5RNbXUrbfgJc5gsXIAwZpRgmXdaNhyXnMbX0VOY3OmzPMp7a3j3MBWVGn5(G5gsXI8VbA91sXI81ZGy3OGcJrHCdPyrnR5NvdM4b29alUXmiM(fv(gK4Xp5Zo7gGqCjvXe72CGV42Cd(fSj3hmNDG74T5g8lytUpyo7ahkUn3GFbBY9bZzh4o52Cd(fSj3hmNDGV9T5gsXI8VbO0I8Vb)c2K7dMZoWXPBZn4xWMCFWCJckmgfYn2IhaB11LsQKovCtKkDf0nKIf5FdsL0PIBIup7a35Vn3qkwK)nuJV1ytHy3GFbBY9bZzh44WT5gsXI8VbPs6urRKOwxNrFd(fSj3hmND2nKKVnh4lUn3qkwK)nQZO1mAfKf5Fd(fSj3hmNDG74T5g8lytUpyUrbfgJc5gyRUU06mA3ePs7u5VHuSi)B0ccETqk8tI8p7ahkUn3GFbBY9bZnkOWyui3WKj)gTfe866mAk)c2KBpa0EGonkPs6urRKOwdsINIyvjEIhaopGHKAEQTqLVHuSi)BuNrRXYPD2bUtUn3GFbBY9bZnkOWyui3aB11LwNr7MivkXKc8Ea429a46bwSThaspa2QRlfBMzpxjgDfKhWHBiflY)gKveI)MrAl1Qs)mHC2b(23MBWVGn5(G5gfuymkKBGKO1Cn)gv6MqJ3daNhybuVHuSi)B0ccEDDg9zh440T5gsXI8VHA8ng)nJUb)c2K7dMZoWD(BZn4xWMCFWCJckmgfYnqs0AUMFJkDtOX7bGZdSThaApasIwZ18BuPBcTxrIf57bCQhWrOEdPyr(3GujDQOliHuD2booCBUb)c2K7dMBiflY)gQX3AclOBeVXi0kithU3WIc8e42DeAClzo7u5P1z0ASCA0vqGbgU4AYKFJsQKov0kjQ11z0u(fSj3qxYC2PYtjvsNkALe166mA6kihadmC3Ijt(nkPs6urRKOwxNrt5xWMCdDjZzNkpvn(wJnfIrxb5GdoCJ4ngHwbz6qvL7qm(glUrPsI)glo7ahh72CdPyr(3GujDQOvsuRbjXFd(fSj3hmND2nktwQ5BZb(IBZnKIf5FJ6mAnJwbzr(3GFbBY9bZzh4oEBUb)c2K7dMBuqHXOqUb2QRlToJ2nrQ0ov(BiflY)gTGGxlKc)Ki)ZoWHIBZnKIf5FJ6mAnwoTBWVGn5(G5SdCNCBUb)c2K7dMBuqHXOqUHji8SrTqL1wQ7G9ao1dafEaWaZdGT66sRZODtKkTtL)gsXI8VbPs6urRKOw3SyvNDGV9T5g8lytUpyUrbfgJc5gyRUU06mA3ePsjMuG3da3UhaxpWIT9aq6bWwDDPyZm75kXORG8aoCdPyr(3GSIq83msBPwv6NjKZoWXPBZn4xWMCFWCJckmgfYnqs0AUMFJkDtOX7bGZdSaQ3qkwK)nAbbVUoJ(SdCN)2CdPyr(3qn(gJ)Mr3GFbBY9bZzh44WT5gsXI8VHA8TgBke7g8lytUpyo7ahh72CdPyr(3GujDQOvsuRRZOVb)c2K7dMZoWxa1BZn4xWMCFWCJckmgfYnW1dGKO1Cn)gv6MqJ3daNhyBpa0EaKeTMR53Os3eAVIelY3d4upGJEah8aGbMhajrR5A(nQ0nH2RiXI89aW5bC8gsXI8VbPs6urxqcP6Sd8flUn3GFbBY9bZnkOWyui3ylEatM8Bu1GWiNr5xWMC7bG2dSfpGjt(nAli411z0u(fSj33qkwK)nivsNkALe1Aqs83WeeE20H7nqSlIjvc2K9aq7bmbHNnQfQS2sDhShaopGto7aFHJ3MBWVGn5(G5gfuymkKBGRhWeeE2OwOYAl1DWEa48a4KhWHBiflY)g1IkOaffTLRLQByccpB6W9gi2fXKkbBYNDGVakUn3GFbBY9bZnkOWyui3axpGjt(nQAqyKZO8lytU9aq7bmbHNnQfQS2sDhShaopGt8aoCdPyr(3OwubfOOOTCTuDdtq4zthU3OtJsQKov0kjQ1GK4Pi2fXKkbBYNDGVWj3MBiflY)g1z0Alri(TBWVGn5(G5Sd8fBFBUb)c2K7dMBiflY)gQX3AclOBeVXi0ki7glUrbfgJc5geq8CQnbHNncvn(wtyb5bGZd44nkvs83yXzh4lWPBZn4xWMCFWCdPyr(3qn(w7ofNDJ4ngHwbz6W9gwuGNa3UJqJBjZzNkpToJwJLtJUccmWWfxtM8BusL0PIwjrTUoJMYVGn5g6sMZovEkPs6urRKOwxNrtxb5ayGH7wmzYVrjvsNkALe166mAk)c2KBOlzo7u5PQX3ASPqm6kihCWHBeVXi0kithQQChIX3yXnkvs83yXzh4lC(BZnKIf5FdsL0PIwjrTgKe)n4xWMCFWC2zNDJAgrI8pWDeQlWbOIdqfNOoUWrO4gkc6Jhp5gq5qzqPahhbCNl4CpGhytf7bcvqjY8aUjYdS1K4Xp5T2dGyC8RbIBpajvzpGSAPQyC7bkvYJNju)sN74zpGtW5EaC08RzKXThyRXxAQQGZ2ApGLEGTgFP3ApaUlWzoq9l9lXrubLiJBpW2EaPyr(EGzqmc1V8geqC5a3XTXHBacLUXKVbuIhyRaNXLvJBpag7Mi2dusvmX8aym(4jupauwPWGmIh4Z35ujiv31PhqkwKpXdK)0zu)sPyr(ekiexsvmX2DNcbE)sPyr(ekiexsvmXGChc3mB)sPyr(ekiexsvmXGChczfVk)Myr((LqjEGXlGivP5bqs0EaSvxxU9aetmIhaJDte7bkPkMyEamgF8epG8ThaeIDoGsZIhVhiiEGoFM6xkflYNqbH4sQIjgK7qqEbePknnXeJ4xkflYNqbH4sQIjgK7qakTiF)sPyr(ekiexsvmXGChcsL0PIBIuHnC33c2QRlLujDQ4Miv6ki)sPyr(ekiexsvmXGChc14Bn2uiMFPuSiFcfeIlPkMyqUdbPs6urRKOwxNr7x6xcL4b2kWzCz142dW1mYzEaluzpGvXEaPyjYdeepGulXuWMm1VukwKpzhuAr(WgU7yRUUuSzM9CLyuelfdmWmbHNnQfQS2sDhSt3XbOcgyMGWZgTILPvrbvmNcfB7xcLiflYNa5oe1ckeSjd7lQ8ENgrVcc2e0oHnyRL5kV3PrjvsNkALe1Aqs8ulkWhpEO70O1IkOaffTLRLkQff4JhVFPuSiFcK7qGwFTuSiF9migSVOY7sYWgU7eq8CQnbHNncvn(wtybbhUBd5ITstM8Bu1GWiNr5xWMC7GFPuSiFcK7qGwFTuSiF9migSVOY7Ljl1mSH7UuSOM18ZQbtGBHFPuSiFcK7qGwFTuSiF9migSVOY7K4Xpzyd3DPyrnR5NvdMSVWV0VukwKpHkjVxNrRz0kilY3VukwKpHkjd5oeTGGxlKc)KiFyd3DSvxxADgTBIuPDQ8(LsXI8jujzi3HOoJwJLtd2WD3Kj)gTfe866mAk)c2KBO70OKkPtfTsIAnijEkIvL4jWziPMNAluz)sPyr(eQKmK7qqwri(BgPTuRk9ZecSH7o2QRlToJ2nrQuIjf4HBh3fBdj2QRlfBMzpxjgDfKd(LsXI8jujzi3HOfe866mAyd3DKeTMR53Os3eA8WTaQ(LsXI8jujzi3Hqn(gJ)Mr(LsXI8jujzi3HGujDQOliHubB4UJKO1Cn)gv6MqJhUTHgjrR5A(nQ0nH2RiXI8DQJq1VukwKpHkjd5oeQX3Acliylvs87lGnEJrOvqMouv5oeJ3xaB8gJqRGmD4UBrbEcC7ocnULmNDQ806mAnwon6kiWadxCnzYVrjvsNkALe166mAk)c2KBOlzo7u5PKkPtfTsIADDgnDfKdGbgUBXKj)gLujDQOvsuRRZOP8lytUHUK5StLNQgFRXMcXORGCWbh8lLIf5tOsYqUdbPs6urRKOwdsI3V0VukwKpHwMSuZ71z0AgTcYI89lLIf5tOLjl1mK7q0ccETqk8tI8HnC3XwDDP1z0UjsL2PY7xkflYNqltwQzi3HOoJwJLtZVukwKpHwMSuZqUdbPs6urRKOw3SyvWAccpB6WD3eeE2OwOYAl1DWofkadmSvxxADgTBIuPDQ8(LsXI8j0YKLAgYDiiRie)nJ0wQvL(zcb2WDhB11LwNr7MivkXKc8WTJ7ITHeB11LInZSNReJUcYb)sPyr(eAzYsnd5oeTGGxxNrdB4UJKO1Cn)gv6MqJhUfq1VukwKpHwMSuZqUdHA8ng)nJ8lLIf5tOLjl1mK7qOgFRXMcX8lLIf5tOLjl1mK7qqQKov0kjQ11z0(LsXI8j0YKLAgYDiivsNk6csivWgU74IKO1Cn)gv6MqJhUTHgjrR5A(nQ0nH2RiXI8DQJoagyijAnxZVrLUj0EfjwKpCo6xkflYNqltwQzi3HGujDQOvsuRbjXdRji8SPd3De7IysLGnzOnbHNnQfQS2sDhmCob2WDFlMm53OQbHroJYVGn5g6TyYKFJ2ccEDDgnLFbBYTFPuSiFcTmzPMHChIArfuGII2Y1sfSMGWZMoC3rSlIjvc2KHnC3X1eeE2OwOYAl1DWWHto4xkflYNqltwQzi3HOwubfOOOTCTubRji8SPd39onkPs6urRKOwdsINIyxetQeSjdB4UJRjt(nQAqyKZO8lytUH2eeE2OwOYAl1DWW5eh8lLIf5tOLjl1mK7quNrRTeH438lLIf5tOLjl1mK7qOgFRjSGG1eeE20H7obepNAtq4zJqvJV1ewqW5iSLkj(9fWgVXi0kiBFHFPuSiFcTmzPMHChc14BT7uCgSLkj(9fWgVXi0kithQQChIX7lGnEJrOvqMoC3TOapbUDhHg3sMZovEADgTglNgDfeyGHlUMm53OKkPtfTsIADDgnLFbBYn0LmNDQ8usL0PIwjrTUoJMUcYbWad3TyYKFJsQKov0kjQ11z0u(fSj3qxYC2PYtvJV1ytHy0vqo4Gd(LsXI8j0YKLAgYDiivsNkALe1Aqs8(L(LsXI8jus84N8EDgTMrRGSiF)sPyr(ekjE8tgYDiAbbVwif(jr(WgU7yRUU06mA3ePs7u59lLIf5tOK4Xpzi3HOoJwJLtZVukwKpHsIh)KHChcsL0PIwjrTUzXQGnC3nbHNnQfQS2sDhStHcWaRK5StLNsQKov0kjQ1nlwfTuji8mz3rWad3sMZovEkPs6urRKOw3Syv0sLGWZK9fqxYC2PYtjvsNkALe16MfRIIyvjEItXxAQQGZCWVukwKpHsIh)KHChcYkcXFZiTLAvPFMqGnC3XwDDP1z0UjsLsmPapC74UyBiXwDDPyZm75kXORGCaAtq4zJAHkRTu3bdNJqfQGbMji8SrTqL1wQ7GDQZVTFPuSiFcLep(jd5oeTGGxxNrdB4UJKO1Cn)gv6MqJhUfq1VukwKpHsIh)KHChc14Bm(Bg5xkflYNqjXJFYqUdbPs6urRKOw3SyvWgU7BbB11LwNr7Miv6kiWad3sMZovEkPs6urRKOw3Syv0sLGWZKDhHgB11LwNr7MivkXKc8oDX2o4xkflYNqjXJFYqUdbPs6urxqcPc2WDhjrR5A(nQ0nHgpCBdnsIwZ18BuPBcTxrIf57uhHQFPuSiFcLep(jd5oeQX3ASPqmyd39onkPs6urRKOwdsINArb(4XdDNgTwubfOOOTCTurTOaF849lLIf5tOK4Xpzi3HGujDQOvsuRRZOHnC370OKkPtfTsIAnijEQff4Jhp0DA0ArfuGII2Y1sf1Ic8XJ3VukwKpHsIh)KHChI6mATLie)gSH7ENgLujDQOvsuRbjXtrSQepboNaDNgTwubfOOOTCTurrSQepboN4xkflYNqjXJFYqUdbPs6urRKOwdsIh2WDhXUiMujytgAtq4zJAHkRTu3bdNtGElMm53OQbHroJYVGn5g6TyYKFJ2ccEDDgnLFbBYTFPuSiFcLep(jd5oe1IkOaffTLRLkyd3De7IysLGnzOnbHNnQfQS2sDhmC4eyGHRjt(nQAqyKZO8lytUHUtJsQKov0kjQ1GK4Pi2fXKkbBYo4xkflYNqjXJFYqUdHA8T2Dkod2sLe)(cyJ3yeAfKPdvvUdX49fWgVXi0kithU7wuGNa3UJqJBjZzNkpToJwJLtJUccmWWfxtM8BusL0PIwjrTUoJMYVGn5g6sMZovEkPs6urRKOwxNrtxb5ayGH7wmzYVrjvsNkALe166mAk)c2KBOlzo7u5PQX3ASPqm6kihCWb)sPyr(ekjE8tgYDiivsNkALe1Aqs8ND2Da]] )

    
end
