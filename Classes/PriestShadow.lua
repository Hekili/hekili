-- PriestShadow.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local PTR = ns.PTR


if UnitClassBase( 'player' ) == 'PRIEST' then
    local spec = Hekili:NewSpecialization( 258, true )

    spec:RegisterResource( Enum.PowerType.Insanity, {
        mind_flay = {
            aura = 'mind_flay',
            debuff = true,

            last = function ()
                local app = state.debuff.mind_flay.applied
                local t = state.query_time

                return app + floor( ( t - app ) / class.auras.mind_flay.tick_time ) * class.auras.mind_flay.tick_time
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

                return app + floor( ( t - app ) / class.auras.mind_sear.tick_time ) * class.auras.mind_sear.tick_time
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

        void_torrent = {
            aura = "void_torrent",

            last = function ()
                local app = state.buff.void_torrent.applied
                local t = state.query_time

                return app + floor( t - app )
            end,

            stop = function( x )
                return x == 0
            end,

            interval = 1,
            value = 7.5,
        },

        vamp_touch_t19 = {
            aura = "vampiric_touch",
            set_bonus = "tier19_2pc",
            debuff = true,

            last = function ()
                local app = state.debuff.vampiric_touch.applied
                local t = state.query_time

                return app + floor( ( t - app ) / class.auras.vampiric_touch.tick_time ) * class.auras.vampiric_touch.tick_time
            end,

            interval = function () return state.debuff.vampiric_touch.tick_time end,
            value = 1
        },

        mindbender = {
            aura = "mindbender",

            last = function ()
                local app = state.buff.mindbender.expires - 15
                local t = state.query_time

                return app + floor( ( t - app ) / ( 1.5 * state.haste ) ) * ( 1.5 * state.haste )
            end,

            interval = function () return 1.5 * state.haste end,
            value = function () return state.debuff.surrendered_to_madness.up and 0 or ( state.buff.surrender_to_madness.up and 12 or 6 ) end,
        },

        shadowfiend = {
            aura = "shadowfiend",

            last = function ()
                local app = state.buff.shadowfiend.expires - 15
                local t = state.query_time

                return app + floor( ( t - app ) / ( 1.5 * state.haste ) ) * ( 1.5 * state.haste )
            end,

            interval = function () return 1.5 * state.haste end,
            value = function () return state.debuff.surrendered_to_madness.up and 0 or ( state.buff.surrender_to_madness.up and 6 or 3 ) end,
        },
    } )
    spec:RegisterResource( Enum.PowerType.Mana )
    

    -- Talents
    spec:RegisterTalents( {
        fortress_of_the_mind = 22328, -- 193195
        shadowy_insight = 22136, -- 162452
        shadow_word_void = 22314, -- 205351

        body_and_soul = 22315, -- 64129
        sanlayn = 23374, -- 199855
        intangibility = 21976, -- 288733

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


    spec:RegisterTotem( "mindbender", 136214 )
    spec:RegisterTotem( "shadowfiend", 136199 )


    spec:RegisterHook( "reset_precast", function ()
        if buff.voidform.up then applyBuff( "shadowform" ) end

        if pet.mindbender.active then applyBuff( "mindbender", pet.mindbender.remains ) end
        if pet.shadowfiend.active then applyBuff( "shadowfiend", pet.shadowfiend.remains ) end

        if action.void_bolt.in_flight then
            runHandler( "void_bolt" )
        end
    end )


    spec:RegisterHook( 'runHandler', function( ability )
        -- Make sure only the correct debuff is applied for channels to help resource forecasting.
        if ability == "mind_sear" then
            removeDebuff( "target", "mind_flay" )
        elseif ability == "mind_flay" then
            removeDebuff( "target", "mind_sear" )
        else
            removeDebuff( "target", "mind_flay" )
            removeDebuff( "target", "mind_sear" )
        end
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
        focused_will = {
            id = 45242,
            duration = 8,
            max_stack = 2,
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
            duration = 6,
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
        mindbender = {
            duration = 15,
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
        shadowfiend = {
            duration = 15,
            max_stack = 1
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
            duration = 15,
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
        weakened_soul = {
            id = 6788,
            duration = function () return 7.5 * haste end,
            max_stack = 1,
        },


        -- Azerite Powers
        chorus_of_insanity = {
            id = 279572,
            duration = 120,
            max_stack = 120,
        },

        death_denied = {
            id = 287723,
            duration = 10,
            max_stack = 1,
        },

        depth_of_the_shadows = {
            id = 275544,
            duration = 12,
            max_stack = 30
        },

        searing_dialogue = {
            id = 288371,
            duration = 1,
            max_stack = 1
        },

        thought_harvester = {
            id = 288343,
            duration = 20,
            max_stack = 1
        },

    } )


    spec:RegisterHook( "advance_end", function ()
        if buff.voidform.up and insanity.current == 0 then
            insanity.regen = 0
            removeBuff( "voidform" )
            if buff.surrender_to_madness.up then
                removeBuff( "surrender_to_madness" )
                applyDebuff( "player", "surrendered_to_madness" )
            end
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
                gain( 6, "insanity" )
            end,
        },
        

        dispersion = {
            id = 47585,
            cast = 0,
            cooldown = function () return talent.intangibility.enabled and 90 or 120 end,
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
                if azerite.death_denied.enabled then applyBuff( "death_denied" ) end
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
                gain( 6, "insanity" )
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

            copy = { "shadow_word_void", 205351, 8092 },
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
                
                forecastResources( "insanity" )
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

                removeBuff( "thought_harvester" )
                if azerite.searing_dialogue.enabled then applyDebuff( "target", "searing_dialogue" ) end
                forecastResources( "insanity" )
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
                applyBuff( "mindbender" )
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

            nodebuff = "weakened_soul",
            
            startsCombat = false,
            texture = 135940,
            
            handler = function ()
                applyBuff( "power_word_shield" )
                applyDebuff( "weakened_soul" )
                if talent.body_and_soul.enabled then applyBuff( "body_and_soul" ) end
                gain( 6, "insanity" )
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
                gain( 6, "insanity" )
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

            spend = -20,
            spendType = "insanity",
            
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
                removeBuff( "depth_of_the_shadows" )
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
        

        shadowfiend = {
            id = 34433,
            cast = 0,
            cooldown = 180,
            gcd = "spell",
            
            toggle = "cooldowns",
            notalent = "mindbender",

            startsCombat = true,
            texture = 136199,
            
            handler = function ()
                summonPet( "shadowfiend", 15 )
                applyBuff( "shadowfiend" )
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

            debuff = "casting",
            readyTime = state.timeToInterrupt,

            handler = function ()
                interrupt()
                applyDebuff( "target", "silence" )
            end,
        },
        

        surrender_to_madness = {
            id = 193223,
            cast = 0,
            cooldown = 180,
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
                return buff.surrender_to_madness.up and -40 or -20
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
            cast = function ()
                if pvptalent.void_origins.enabled then return 0 end
                return haste * ( talent.legacy_of_the_void.enabled and 0.6 or 1 ) * 2.5 
            end,
            cooldown = 0,
            gcd = "spell",
            
            spend = function ()
                return talent.legacy_of_the_void.enabled and 60 or 90
            end,
            spendType = "insanity",
            
            startsCombat = true,
            texture = 1386548,

            nobuff = "voidform",
            bind = "void_bolt",
            
            -- ready = function () return insanity.current >= ( talent.legacy_of_the_void.enabled and 60 or 90 ) end,
            handler = function ()
                applyBuff( "voidform", nil, ( level < 116 and equipped.mother_shahrazs_seduction ) and 3 or 1 )
                gain( talent.legacy_of_the_void.enabled and 60 or 90, "insanity" )
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


    spec:RegisterPack( "Shadow", 20181230.2119, [[dy0YQaqiOQ0JGK0MGu9jrkvnkrQoLQiRcscVsvvZcsClOQyxc(LiAyIKogsSmKupdQQMMirxdjPTjsW3GKkJtvuDoijADQII5HK4EsL9bHoOQOulecEOiLYeHKsCrvrj9rrkvCsiPuRue2PQkdvKqlfskEQOMQQWxHKsAVk(RedwkhM0IHYJfAYaxg1MjYNHkJwQ60uwTQOeVgsz2s62i1Uv53knCvPJlsPslh0ZrmDQUorTDvLVdrJhsQ68IuSErkz(qv2pHhkZJjduNNFuNkLNtHA8NAGAkuqLPKYK908Yt(vJOP44jFknp5CVcwKt(vttDvW8yYKvgg5j37(l5zsMeN59YyH4sNKy0Yv1T9IqvYtsm6ysS6ILetsXha)L8fUswLjjtriJAudqsMIOMskcnM4LCVcwKbIrhNmMSvDu7BWMmqDE(rDQuEofQXFQbQPqbvIFktwL9(fo5SrN2MCVba8nytgWK4Krvrl3RGfPOLIqJjUibQkA9U)sEMKjXzEVmwiU0jjgTCvDBViuL8KeJoMeRUyjXKu8bWFjFHRKvzsYueYOg1aKKPiQPKIqJjEj3RGfzGy0rrcuv0qTWrMgJHIg(tffrJ6uP8CrdFenQP8muEUiHibQkAPTE9WXKNrKavfn8r0E2aadeTSv5lYbrcuv0WhrlTT3hdDgiAUcXXEXKensAoxr9HjxnItMhtMyhUkppMFuMhtwJUT3K)wduyO8RB7nz(uSkdgegF(r98yY8Pyvgmim5i0CgA6KXKLKcFRbKwiDaSiVjRr32BYafIwrjr(i2EJp)W)8yYA0T9M83AGc2w9jZNIvzWGW4ZVuopMmFkwLbdctocnNHMozmzjPqVc)yIZGI3VY46Dsq(v0qx0I7wblYl8TgOGTvpazA1oIOHyNOrjqvrdDrttlgAohiScTdxbyADXjZbOEOjAi2jAuMSgDBVjtBhOqyfo(8JQZJjZNIvzWGWKJqZzOPt2vio2dUrZfFlaJfnQiA4x0WdprlUBfSiVaPxblYcYfckaw9(qSxH4yIO1jAulA4HNOLUOf3TcwKxG0RGfzb5cbfaREFi2RqCmr06enkIg6IwC3kyrEbsVcwKfKleuaS69bitR2renQiA4IGaTI6fTNMSgDBVjt6vWISGCHGcGvVF85xkmpMmFkwLbdctocnNHMozmzjPW3AaPfshiUgrt0qu0OKQO9x0sx0OKQOHkenmzjPawDxqvM4b5xr7PjRr32BYeziKpadl(wOvWXeY4Zpu38yY8Pyvgmim5i0CgA6KHQbk8hFEqbasWordrrJsQtwJUT3KbkeTY3AGXNFpFEmzn62EtM2oagFagoz(uSkdgegF(HkNhtMpfRYGbHjhHMZqtNm(kAyYssHV1aslKoi)kA4HNOLUOf3TcwKxG0RGfzb5cbfaREFi2RqCmr06enQfn0fnmzjPW3AaPfshiUgrt0OIOrHQI2ttwJUT3Kj9kyrwqUqqbWQ3p(8JsQZJjZNIvzWGWKJqZzOPtgQgOWF85bfaib7enefnQkAOlAq1af(JppOaajaKHQB7jAur0Oo1jRr32BYKEfSilrOs6hF(rHY8yY8Pyvgmim5i0CgA6K)uOPyvoawNuKFNSgDBVjtBhOGvvIp(8Jc1ZJjZNIvzWGWKJqZzOPtgSEG0RGfzb5cbLx1UaKPv7iIgIIwkfn0fnW6HpL(1GwS4RCSpazA1oIOHOOLYjRr32BYFRbk(cH85Jp)OG)5XK5tXQmyqyYrO5m00jdzjit6vSklAOlAUcXXEWnAU4BbySOHOOLsrdDrdFfnxR85bAJWW0e4tXQmq0qx0WxrZ1kFEaOq0kFRbc8Pyvgmzn62EtM0RGfzb5cbLx1UXNFus58yY8Pyvgmim5i0CgA6KHSeKj9kwLfn0fnxH4yp4gnx8Tamw0qu0sbrdp8eT0fnxR85bAJWW0e4tXQmq0qx0aRhi9kyrwqUqq5vTlazjit6vSklApnzn62Et(tPFnOfl(kh7hF(rHQZJjZNIvzWGWK1OB7nzA7afcRWjBNZqO8RxmPj7wencIDupz7CgcLF9IrtZatDEYuMCeAodnDYAAXqZ5aHvOD4katRlozoa1dnrdXord)to2R2nzkJp)OKcZJjZNIvzWGWK1OB7nzA7afPQMMjBNZqO8RxmPj7wencIDuJE6XDRGf5f(wduW2QhKFXdV4UvWI8c02bkyvL4b53NMSDodHYVEXOPzGPopzkto2R2nzkJp)OG6MhtwJUT3Kj9kyrwqUqq5vTBY8Pyvgmim(4tgWsQC1NhZpkZJjRr32BYeRYxKNmFkwLbdcJp)OEEmzn62EtwMWfZzAYK5tXQmyqy85h(NhtMpfRYGbHjhHMZqtNmMSKuaRUlOkt8aK1OlA4HNO5keh7b3O5IVfGXIgv6eTNNQOHhEIMRqCSh6zT69H3OlAur0WpvNSgDBVj)UUT34ZVuopMmFkwLbdctEFNmH9jRr32BYFk0uSkp5pTkZtgSEG0RGfzb5cbLx1UGBr0SdNOHUObwp8P0Vg0IfFLJ9b3IOzhUj)PWYP08KbRtkYVJp)O68yY8Pyvgmim5i0CgA6KXKLKcFRbKwiDq(DYA0T9MSKbzS6UGXNFPW8yYA0T9Mmgdjmen7Wnz(uSkdgegF(H6MhtwJUT3KRgUENuEwKb4O5ZNmFkwLbdcJp)E(8yY8Pyvgmim5i0CgA6KXKLKcFRbKwiDq(DYA0T9MSErM4qTwIATo(8dvopMmFkwLbdctocnNHMozYlxRfxH4yNeOTduiScfnefT0fnQkA)fnkIgQq0CTYNhOncdttGpfRYar7PjRr32BYq5ROr32RunIp5Qr8YP08K1LhF(rj15XK5tXQmyqyYrO5m00jRr3(4cFmTXerdrrJYK1OB7nzO8v0OB7vQgXNC1iE5uAEYXkRF84ZpkuMhtMpfRYGbHjhHMZqtNSgD7Jl8X0gteTorJYK1OB7nzO8v0OB7vQgXNC1iE5uAEYe7Wv5XhFYVqoU0yQppMFuMhtMpfRYGbHXNFuppMmFkwLbdcJp)W)8yY8Pyvgmim(8lLZJjZNIvzWGW4ZpQopMSgDBVj)UUT3K5tXQmyqy85xkmpMmFkwLbdctocnNHMoz8v0WKLKcKEfSiLwiDq(DYA0T9MmPxblsPfsp(8d1npMSgDBVjtBhOGvvIpz(uSkdgegF(985XK1OB7nzA7afSQs8jZNIvzWGW4JpzD55X8JY8yYA0T9M83AGcdLFDBVjZNIvzWGW4ZpQNhtMpfRYGbHjhHMZqtNmMSKu4BnG0cPdGf5nzn62EtgOq0kkjYhX2B85h(NhtMpfRYGbHjhHMZqtNSRv(8aqHOv(wde4tXQmq0qx0aRhi9kyrwqUqq5vTlazA1oIOHOO5q9JRf3O5jRr32BYFRbkyB1hF(LY5XK5tXQmyqyYrO5m00jJjljf(wdiTq6aX1iAIgIIgLufT)Iw6IgLufnuHOHjljfWQ7cQYepi)kApnzn62EtMidH8byyX3cTcoMqgF(r15XK5tXQmyqyYrO5m00jdvdu4p(8GcaKGDIgIIgLuNSgDBVjduiALV1aJp)sH5XK1OB7nzA7ay8by4K5tXQmyqy85hQBEmz(uSkdgeMCeAodnDYq1af(JppOaajyNOHOOrvrdDrdQgOWF85bfaibGmuDBprJkIg1Pozn62EtM0RGfzjcvs)4ZVNppMmFkwLbdctwJUT3KPTduiScNSDodHYVEXKMSBr0ii2rn6Ph3TcwKx4BnqbBREq(fp8I7wblYlqBhOGvvIhKFFAY25mek)6fJMMbM68KPm5yVA3KPm(8dvopMSgDBVjt6vWISGCHGYRA3K5tXQmyqy8XNCSY6hppMFuMhtwJUT3K)wduyO8RB7nz(uSkdgegF(r98yY8Pyvgmim5i0CgA6KXKLKcFRbKwiDaSiVjRr32BYafIwrjr(i2EJp)W)8yYA0T9M83AGc2w9jZNIvzWGW4ZVuopMmFkwLbdctocnNHMozxH4yp4gnx8Tamw0OIOHFrdp8enmzjPW3AaPfshalYBYA0T9MmPxblYcYfckaw9(XNFuDEmz(uSkdgeMCeAodnDYyYssHV1aslKoqCnIMOHOOrjvr7VOLUOrjvrdviAyYssbS6UGQmXdYVI2ttwJUT3KjYqiFagw8TqRGJjKXNFPW8yY8Pyvgmim5i0CgA6KHQbk8hFEqbasWordrrJsQtwJUT3KbkeTY3AGXNFOU5XK1OB7nzA7ay8by4K5tXQmyqy853ZNhtMpfRYGbHjhHMZqtNC6Ig5LR1IRqCStc02bkewHIgveTukAOlAAAXqZ5aHvOD4katRlozoa1dnrRt0sv0Es0WdprlDrJ8Y1AXvio2jbA7afcRqrJkIg(fn0fnnTyO5CGWk0oCfGP1fNmhG6HMO1jAueTNen8Wt0sx0iVCTwCfIJDsG2oqHWku0OIOrTOHUOPPfdnNdewH2HRamTU4K5aup0ene7enQfTNMSgDBVjtBhOGvvIp(8dvopMmFkwLbdctocnNHMo50fnOAGc)XNhuaGeSt0qu0OQOHUObvdu4p(8GcaKaqgQUTNOrfrJAr7jrdp8enOAGc)XNhuaGeaYq1T9enefnQNSgDBVjt6vWISeHkPF85hLuNhtMpfRYGbHjhHMZqtNmKLGmPxXQSOHUO5keh7b3O5IVfGXIgIIwkfn0fT0fn8v0CTYNhOncdttGpfRYardDrdFfnxR85bGcrR8TgiWNIvzGO90K1OB7nzsVcwKfKleuEv7gF(rHY8yY8Pyvgmim5i0CgA6KHSeKj9kwLfn0fT0fnxH4yp4gnx8Tamw0qu0sbr7PjRr32BYFk9RbTyXx5y)4ZpkuppMmFkwLbdctocnNHMozW6bsVcwKfKleuEv7cqwcYKEfRYIg6Iw6IMRv(8aTryyAc8PyvgiAOlAUcXXEWnAU4BbySOHOOLsr7PjRr32BYFk9RbTyXx5y)4Zpk4FEmzn62Et(BnqXxiKpFY8Pyvgmim(8JskNhtMpfRYGbHjRr32BY02bkewHt2oNHq5xVyst2TiAee7OEY25mek)6fJMMbM68KPm5i0CgA6KjVCTwCfIJDsG2oqHWku0qu0Om5yVA3KPm(8JcvNhtMpfRYGbHjRr32BY02bksvnnt2oNHq5xVyst2TiAee7Og90J7wblYl8TgOGTvpi)IhEXDRGf5fOTduWQkXdYVpnz7CgcLF9IrtZatDEYuMCSxTBYugF(rjfMhtwJUT3Kj9kyrwqUqq5vTBY8Pyvgmim(4Jp5pgsS9MFuNkLNNkQe)PgO8CQX)KrQWZoCKjJA9zJA(HA)lTZZiAI2JEw0m63f6IM0cfT0EID4QCAVOb50UYgKbIgzPzrtL9LwDgiAXE9WXKGiXJEw0K2ADrAhortLHkr0qYqw0Kjmq0St08Ew00OB7jAvJ4IgMSlAizilA36IM0kFarZorZ7zrtbG9enG6kMs4NrKq0WhrRxHFmXzqX7xzC9orKqKa1M(DHodenQkAA0T9eTQrCsqKyYKxoo)OMQpFYVWvYQ8Krvrl3RGfPOLIqJjUibQkA9U)sEMKjXzEVmwiU0jjgTCvDBViuL8KeJoMeRUyjXKu8bWFjFHRKvzsYueYOg1aKKPiQPKIqJjEj3RGfzGy0rrcuv0qTWrMgJHIg(tffrJ6uP8CrdFenQP8muEUiHibQkAPTE9WXKNrKavfn8r0E2aadeTSv5lYbrcuv0WhrlTT3hdDgiAUcXXEXKensAoxr9brcrcuv0Ewr9Cu2zGOHXslKfT4sJPUOHX4SJeeTNDmYVor0U9WNEfsljxfnn62EerBVAAcIeA0T9iHxihxAm17KQkbnrcn62EKWlKJlnM6)7skTlqKqJUThj8c54sJP()UKQmoA(C1T9ejqvrlF6lPFDrdQgq0WKLKyGOrC1jIgglTqw0IlnM6IggJZoIOPhq0EHm(8UUBhorZiIgypoisOr32JeEHCCPXu)FxsYPVK(1lexDIiHgDBps4fYXLgt9)DjFx32tKqJUThj8c54sJP()UKKEfSiLwinkMuh(Ijljfi9kyrkTq6G8RiHgDBps4fYXLgt9)DjPTduWQkXfj0OB7rcVqoU0yQ)VljPxblYcYfckFRbejejqvr7zf1ZrzNbIg)XW0iAUrZIM3ZIMg9fkAgr00p1QkwLdIeA0T9iDeRYxKfj0OB7r(3LuMWfZzAIiHgDBpY)UKVRB7HIj1HjljfWQ7cQYepazn64HNRqCShCJMl(wagtLUNNkE45keh7HEwREF4n6ub)uvKqJUTh5FxYpfAkwLr5uAUdSoPi)IY(2ryhLpTkZDG1dKEfSilixiO8Q2fClIMD4qhSE4tPFnOfl(kh7dUfrZoCIeA0T9i)7skzqgRUlaftQdtwsk8TgqAH0b5xrcn62EK)DjXyiHHOzhorcn62EK)DjRgUENuEwKb4O5Zfj0OB7r(3LuVitCOwlrTwrXK6WKLKcFRbKwiDq(vKqJUTh5FxsO8v0OB7vQgXr5uAUtxgftQJ8Y1AXvio2jbA7afcRqetNQ)PGkCTYNhOncdttGpfRYGNej0OB7r(3LekFfn62ELQrCuoLM7Ivw)yumPon62hx4JPnMGifrcn62EK)DjHYxrJUTxPAehLtP5oID4QmkMuNgD7Jl8X0gt6OisisOr32Je0L7(wduyO8RB7jsOr32Je0L)3LeOq0kkjYhX2dftQdtwsk8TgqAH0bWI8ej0OB7rc6Y)7s(TgOGTvhftQZ1kFEaOq0kFRbc8PyvgGoy9aPxblYcYfckVQDbitR2rq0H6hxlUrZIeA0T9ibD5)DjjYqiFagw8TqRGJjeumPomzjPW3AaPfshiUgrdrkP(pDkPIkWKLKcy1DbvzIhKFFsKqJUThjOl)VljqHOv(wdGIj1bvdu4p(8GcaKGDisjvrcn62EKGU8)UK02bW4dWqrcn62EKGU8)UKKEfSilrOs6rXK6GQbk8hFEqbasWoePk6q1af(JppOaajaKHQB7rfQtvKqJUThjOl)VljTDGcHvikXE1UokOyNZqO8RxmAAgyQZDuqXoNHq5xVysDUfrJGyh1ONEC3kyrEHV1afST6b5x8WlUBfSiVaTDGcwvjEq(9jrcn62EKGU8)UKKEfSilixiO8Q2jsisOr32JeIvw)4UV1afgk)62EIeA0T9iHyL1p(FxsGcrROKiFeBpumPomzjPW3AaPfshalYtKqJUThjeRS(X)7s(TgOGTvxKqJUThjeRS(X)7ss6vWISGCHGcGvVhftQZvio2dUrZfFlaJPc(XdpmzjPW3AaPfshalYtKqJUThjeRS(X)7ssKHq(amS4BHwbhtiOysDyYssHV1aslKoqCnIgIus9F6usfvGjljfWQ7cQYepi)(KiHgDBpsiwz9J)3LeOq0kFRbqXK6GQbk8hFEqbasWoePKQiHgDBpsiwz9J)3LK2oagFagksOr32JeIvw)4)DjPTduWQkXrXK6sN8Y1AXvio2jbA7afcRqQKs010IHMZbcRq7WvaMwxCYCaQhADP(eE4Lo5LR1IRqCStc02bkewHub)ORPfdnNdewH2HRamTU4K5aup06O8eE4Lo5LR1IRqCStc02bkewHuHA010IHMZbcRq7WvaMwxCYCaQhAi2r9tIeA0T9iHyL1p(FxssVcwKLiuj9OysDPdvdu4p(8GcaKGDisv0HQbk8hFEqbasaidv32Jku)eE4bvdu4p(8GcaKaqgQUThIulsOr32JeIvw)4)Djj9kyrwqUqq5vTdftQdYsqM0RyvgDxH4yp4gnx8TamgXuIE64RRv(8aTryyAc8PyvgGo(6ALppauiALV1ab(uSkdEsKqJUThjeRS(X)7s(P0Vg0IfFLJ9OysDqwcYKEfRYONURqCShCJMl(wagJyk8KiHgDBpsiwz9J)3L8tPFnOfl(kh7rXK6aRhi9kyrwqUqq5vTlazjit6vSkJE6Uw5Zd0gHHPjWNIvza6UcXXEWnAU4BbymIP8jrcn62EKqSY6h)Vl53AGIVqiFUiHgDBpsiwz9J)3LK2oqHWkeftQJ8Y1AXvio2jbA7afcRqePGsSxTRJck25mek)6fJMMbM6ChfuSZziu(1lMuNBr0ii2rTiHgDBpsiwz9J)3LK2oqrQQPbLyVAxhfuSZziu(1lgnndm15okOyNZqO8RxmPo3IOrqSJA0tpUBfSiVW3AGc2w9G8lE4f3TcwKxG2oqbRQepi)(KiHgDBpsiwz9J)3LK0RGfzb5cbLx1orcrcn62EKaXoCvU7BnqHHYVUTNiHgDBpsGyhUk)VljqHOvusKpIThkMuhMSKu4BnG0cPdGf5jsOr32Jei2HRY)7s(TgOGTvxKqJUThjqSdxL)3LK2oqHWkeftQdtwsk0RWpM4mO49RmUENeKFrpUBfSiVW3AGc2w9aKPv7ii2rjqv010IHMZbcRq7WvaMwxCYCaQhAi2rrKqJUThjqSdxL)3LK0RGfzb5cbfaREpkMuNRqCShCJMl(wagtf8JhEXDRGf5fi9kyrwqUqqbWQ3hI9keht6Ogp8spUBfSiVaPxblYcYfckaw9(qSxH4yshf0J7wblYlq6vWISGCHGcGvVpazA1ocvWfbbAf1)KiHgDBpsGyhUk)Vljrgc5dWWIVfAfCmHGIj1Hjljf(wdiTq6aX1iAisj1)PtjvubMSKuaRUlOkt8G87tIeA0T9ibID4Q8)UKafIw5BnakMuhunqH)4Zdkaqc2HiLufj0OB7rce7Wv5)DjPTdGXhGHIeA0T9ibID4Q8)UKKEfSilixiOay17rXK6WxmzjPW3AaPfshKFXdV0J7wblYlq6vWISGCHGcGvVpe7vioM0rn6yYssHV1aslKoqCnIgvOq1Nej0OB7rce7Wv5)Djj9kyrwIqL0JIj1bvdu4p(8GcaKGDisv0HQbk8hFEqbasaidv32JkuNQiHgDBpsGyhUk)VljTDGcwvjokMu3NcnfRYbW6KI8RiHgDBpsGyhUk)Vl53AGIVqiFokMuhy9aPxblYcYfckVQDbitR2rqmLOdwp8P0Vg0IfFLJ9bitR2rqmLIeA0T9ibID4Q8)UKKEfSilixiO8Q2HIj1bzjit6vSkJURqCShCJMl(wagJykrhFDTYNhOncdttGpfRYa0XxxR85bGcrR8TgiWNIvzGiHgDBpsGyhUk)Vl5Ns)Aqlw8vo2JIj1bzjit6vSkJURqCShCJMl(wagJykGhEP7ALppqBegMMaFkwLbOdwpq6vWISGCHGYRAxaYsqM0Ryv(jrcn62EKaXoCv(FxsA7afcRqumPonTyO5CGWk0oCfGP1fNmhG6HgID4hLyVAxhfuSZziu(1lgnndm15okOyNZqO8RxmPo3IOrqSJArcn62EKaXoCv(FxsA7afPQMguI9QDDuqXoNHq5xVy00mWuN7OGIDodHYVEXK6ClIgbXoQrp94UvWI8cFRbkyB1dYV4HxC3kyrEbA7afSQs8G87tIeA0T9ibID4Q8)UKKEfSilixiO8Q2n(4Zaa]] )

    
end
