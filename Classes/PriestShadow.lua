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

            stop = function( x )
                return x < 3
            end,

            interval = 1,
            value = function () return ( state.talent.fortress_of_the_mind.enabled and 1.2 or 1 ) * 3 end,
        },

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
            value = function () return state.debuff.void_torrent.up and 0 or -7 end,
        },

        vamp_touch_t19 = {
            aura = "vampiric_touch",
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
            duration = 3,
            max_stack = 1,
        },
        mind_sear = {
            id = 48045,
            duration = 3,
            max_stack = 1,
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
        },
        void_bolt = {
            id = 228266,
        },
        void_torrent = {
            id = 263165,
            duration = 4,
            max_stack = 1,
        },
        voidform = {
            id = 194249,
            duration = 3600,
            max_stack = 25,
            meta = {
                drop_time = function ()
                    if buff.voidform.down then return query_time end

                    local app = buff.voidform.applied
                    app = app + floor( query_time - app )

                    return app + ceil( insanity.current / 7 ) + debuff.void_torrent.remains
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
            gcd = "spell",

            spend = function () return buff.empty_mind.stack + ( ( talent.fortress_of_the_mind.enabled and 1.2 or 1 ) * -12 ) end,
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
            channeled = true,
            breakable = true,
            cooldown = 0,
            gcd = "spell",
            
            startsCombat = true,
            texture = 136208,
            
            handler = function ()
                applyDebuff( "target", "mind_flay" )
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
            channeled = true,
            breakable = true,
            cooldown = 0,
            gcd = "spell",
            
            startsCombat = true,
            texture = 237565,
            
            handler = function ()
                applyDebuff( "target", "mind_sear" )
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
            
            spend = 0.02,
            spendType = "mana",
            
            startsCombat = true,
            texture = 136207,
            
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

            spend = -15,
            spendType = "insanity",
            
            startsCombat = true,
            texture = 610679,
            
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
            
            startsCombat = true,
            texture = 136200,
            
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
            
            startsCombat = true,
            texture = 135978,
            
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

            talent = "void_torrent",
            buff = "voidform",

            handler = function ()
                -- applies voidform (194249)
                -- applies void_torrent (263165)
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


    spec:RegisterPack( "Shadow", 20180806.2123, [[duKPJaqiqv8iquytGkFcevnkLuDkqKvjkf5vkvnlqQBbII2fL(LsLHbk6yIILjk5zIs10qfCnLu2gOQ8nquzCGQ05eLswhik18qf6Ek0(ajhuuk0cbHhkkf1ffLs5JIsbgPOuQojikzLIQMPOuq7ujzOGQQYsbvvvpvKPkQ8vqvvSxj)vObd0HjwmuEmftwLlJSzu1NrLgTs50u9AurZwr3gQ2TQ(TudhqhhuvLwoKNJY0jDDfSDL47amEqvLZdkmFqP9l4ktLRsNOuTklyMbEHj8ct4ZMvMSYEMSvLuyaKQeqXWPWLQ0l4uLsBY1aQeqbgZwUkxLy9aYqvAtvGmi7D74662aM1047yo(WuuVFds41Dmh3SdB2y7W4fiZJw2be18(Ky7Y5ekRm7YLvMi8pKtmnM2KRbyzoUPsyd(uHS(cRsNOuTklyMbEHj8cZ1SzL9S4ahGVkjd6wJQuYXZMR0rmtLYT5SaOZcGsaeOy4u4sbWMpakg17paoDMYcG8nkaMTtC6t3wPPZuwLRsm)5oPkxTktLRsIr9(R0s7xKqdavV)krVGnPRGO0AvwvUkrVGnPRGOsgKReYLkHnWZBxA)4BeU9AaFLeJ69xPtqCgfMHEM3FP1QSx5QKyuV)kT0(fX6Pwj6fSjDfeLwR4qLRs0lyt6kiQKb5kHCPsQG4sQvDCkQD8CkaYXay2dGWcBa0098AaVLTjxdicOrx8ir3SMnbXLybWXaywbqyHnaUEa0098AaVLTjxdicOrx8ir3SMnbXLybWXayMaiCbqt3ZRb8w2MCnGiGgDXJeDZIiCXFwaKJbqUMlacPkjg17VsSn5Aaran6Ihj6wP1Q1QCvIEbBsxbrLmixjKlvcBGN3U0(X3iCltfdNbqOgdGRhaZSwaCFaeBGN3In7(Mdm1oamacPaiCbqvqCj1Qoof1oEofaHkaMfmHzaewydGQG4sQvDCkQD8CkaYXaiKBTkjg17VsSbeI(JqrTJ4Y9eJvATc(QCvIEbBsxbrLmixjKlvcj(fPf6vRChZ6FaeQaygywjXOE)v6eeNXL2VsRvqUkxLeJ69xjC)pm6pcvj6fSjDfeLwRG3kxLOxWM0vqujdYvc5sLGNai2apVDP9JVr42bGbqyHnaUEa0098AaVLTjxdicOrx8ir3SMnbXLybWXaywbq4cGyd882L2p(gHBzQy4maYXayM1cGqQsIr9(ReBtUgqeqJU4rIUvATkBv5Qe9c2KUcIkzqUsixQes8lsl0Rw5oM1)aiubW1cGWfarIFrAHE1k3XS3asuV)aihdGzbZkjg17VsSn5AardsyBLwRYaZkxLOxWM0vqujdYvc5sLweKlytYETYIdaRKyuV)kH7)fXMctlTwLjtLRs0lyt6kiQKb5kHCPsxRw2MCnGiGgDrGI)weHl(ZcGqfa5qaeUa41QDrWb6i3e1EWSzreU4placvaKdvsmQ3FLwA)IAJq0RLwRYKvLRs0lyt6kiQKb5kHCPsiIhrSnbBsbq4cGQG4sQvDCkQD8CkacvaKdbq4cGWtauLj9Qf3zecgw6fSjDbq4cGWtauLj9Q9eeNXL2pl9c2KUkjg17VsSn5Aaran6Iaf)lTwLj7vUkrVGnPRGOsgKReYLkHiEeX2eSjfaHlaQcIlPw1XPO2XZPaiubq4laclSbW1dGQmPxT4oJqWWsVGnPlacxa8A1Y2KRbeb0Olcu83IiEeX2eSjfaHuLeJ69xPfbhOJCtu7bZwP1QmCOYvj6fSjDfevsmQ3FLW9)I8tbgvYFLqObGA05RK6gozqnMfCRB6EEnG3U0(fX6PAhaclSMUNxd4T4(FrSPWu7aqivj)vcHgaQrhhNoxuQszQKzt8VszkTwLzTkxLeJ69xj2MCnGiGgDrGI)vIEbBsxbrPLwPJ4LHPw5QvzQCvIEbBsxbrLmixjKlvcBGN3In7(Mdm1IiXObqyHnaQcIlPw1XPO2XZPaihhdGWlmdGWcBaufexsTBKm1nlqJga5yam7RvjXOE)vcyRE)LwRYQYvj6fSjDfevQbwjgPvsmQ3FLweKlytQslYCGQ01QLTjxdicOrxeO4VvDdN(Znacxa8A1Ui4aDKBIApy2SQB40FUvArqXxWPkDTYIdalTwL9kxLOxWM0vqujXOE)vcn8rXOE)XPZ0kzqUsixQedinNrvqCjLzX9)ImsqbqOcGRhaxlaUpaMjaMnfavzsVAXDgHGHLEbBsxaesvA6mn(covjPPsRvCOYvj6fSjDfevsmQ3FLqdFumQ3FC6mTsgKReYLkjg1xOi9eUtSaiubWmvA6mn(covjZKKfQ0A1AvUkrVGnPRGOsIr9(ReA4JIr9(JtNPvYGCLqUujXO(cfPNWDIfahdGzQ00zA8fCQsm)5oPslTsarKPXXeTYvRYu5Qe9c2KUcIsRvzv5Qe9c2KUcIsRvzVYvj6fSjDfeLwR4qLRs0lyt6kikTwTwLRsIr9(ReWw9(Re9c2KUcIsRvWxLRs0lyt6kiQKb5kHCPsWtaeBGN3Y2KRbW3iC7aWkjg17VsSn5Aa8ncV0AfKRYvjXOE)vc3)lInfMwj6fSjDfeLwRG3kxLeJ69xj2MCnGiGgDXL2VkrVGnPRGO0sRK0uLRwLPYvjXOE)vAP9lsObGQ3FLOxWM0vquATkRkxLOxWM0vqujdYvc5sLWg45TlTF8nc3EnGVsIr9(R0jioJcZqpZ7V0Av2RCvIEbBsxbrLmixjKlvsLj9Q9eeNXL2pl9c2KUaiCbWRvlBtUgqeqJUiqXFlIWf)zbqOcGkswOzuDCQsIr9(R0s7xeRNAP1kou5Qe9c2KUcIkzqUsixQe2apVDP9JVr4wMkgodGqngaxpaMzTa4(ai2apVfB29nhyQDayaesvsmQ3FLydie9hHIAhXL7jgR0A1AvUkrVGnPRGOsgKReYLkHe)I0c9QvUJz9pacvamdmRKyuV)kDcIZ4s7xP1k4RYvjXOE)vc3)dJ(JqvIEbBsxbrP1kixLRs0lyt6kiQKb5kHCPsiXViTqVAL7yw)dGqfaxlacxaej(fPf6vRChZEdir9(dGCmaMfmRKyuV)kX2KRbeniHTvATcERCvIEbBsxbrLeJ69xjC)ViJeuL8xjeAaOgD(kPUHtguJzb36MUNxd4TlTFrSEQ2bGWcRP751aElU)xeBkm1oaesvYFLqObGA0XXPZfLQuMkz2e)RuMsRvzRkxLeJ69xj2MCnGiGgDrGI)vIEbBsxbrPLwjZKKfQYvRYu5QKyuV)kT0(fj0aq17Vs0lyt6kikTwLvLRs0lyt6kiQKb5kHCPsyd882L2p(gHBVgWxjXOE)v6eeNrHzON59xATk7vUkjg17VslTFrSEQvIEbBsxbrP1kou5Qe9c2KUcIkzqUsixQKkiUKAvhNIAhpNcGCmaM9aiSWgaXg45TlTF8nc3EnGVsIr9(ReBtUgqeqJU4rIUvATATkxLOxWM0vqujdYvc5sLWg45TlTF8nc3YuXWzaeQXa46bWmRfa3haXg45TyZUV5atTdadGqQsIr9(ReBaHO)iuu7iUCpXyLwRGVkxLOxWM0vqujdYvc5sLqIFrAHE1k3XS(haHkaMbMvsmQ3FLobXzCP9R0AfKRYvjXOE)vc3)dJ(JqvIEbBsxbrP1k4TYvjXOE)vc3)lInfMwj6fSjDfeLwRYwvUkrVGnPRGOsgKReYLkTEaej(fPf6vRChZ6FaeQa4Abq4cGiXViTqVAL7y2BajQ3FaKJbWScGqkaclSbqK4xKwOxTYDm7nGe17pacvamRkjg17VsSn5AardsyBLwRYaZkxLOxWM0vqujdYvc5sLqepIyBc2KcGWfavbXLuR64uu745uaeQaihcGWfaHNaOkt6vlUZiemS0lyt6cGWfaHNaOkt6v7jioJlTFw6fSjDvsmQ3FLyBY1aIaA0fbk(xjdmmtkQcIlPSAvMsRvzYu5Qe9c2KUcIkzqUsixQeI4reBtWMuaeUa46bqvqCj1Qoof1oEofaHkacFbqivjXOE)vArWb6i3e1EWSvjdmmtkQcIlPSAvMsRvzYQYvj6fSjDfevYGCLqUuPRvlBtUgqeqJUiqXFlI4reBtWMuaeUa46bqvM0RwCNriyyPxWM0faHlaQcIlPw1XPO2XZPaiubqoeaHuLeJ69xPfbhOJCtu7bZwLmWWmPOkiUKYQvzkTwLj7vUkjg17VslTFrTri61krVGnPRGO0Avgou5Qe9c2KUcIkjg17Vs4(FrgjOk5Vsi0aqTszQKb5kHCPsmG0CgvbXLuMf3)lYibfaHkaMvLmBI)vktP1QmRv5Qe9c2KUcIkjg17Vs4(Fr(PaJk5Vsi0aqn68vsDdNmOgZcU1nDpVgWBxA)Iy9uTdaHfwt3ZRb8wC)Vi2uyQDaiKQK)kHqda1OJJtNlkvPmvYSj(xPmLwRYaFvUkjg17VsSn5Aaran6Iaf)Re9c2KUcIslT0kbqqV)Czvc(t2i8)vqwRYgazhadG52OaOJdSrAaKVrbqipZFUtcYhare83bhrxaK14uaug0gxu6cGMn55smBiF2q)PaihGSdGzZ9VqiLUaiKNR5S4c8dYha1oac55AoiFaC9mWpizd5d5HSWb2iLUa4AbqXOE)bWPZuMnKVsmGKPwL1AWBLaIAEFsvcYiaMTb)iZGsxaeJ4BefannoMObqmIR)mBamB0yiGkla(9dzUjiC(HzaumQ3pla2)eg2qEXOE)mlqezACmrh5NcJZqEXOE)mlqezACmr3pUJV7lKxmQ3pZcerMght09J7KbU40RI69hYdzeatVaKT1Aaej(faXg45PlaYurzbqmIVrua004yIgaXiU(ZcGYFbqGicYeyRQ)CdGolaE9t2qEXOE)mlqezACmr3pUJ9cq2wRrMkklKxmQ3pZcerMght09J7a2Q3FiVyuVFMfiImnoMO7h3X2KRbW3iCOD(r4bBGN3Y2KRbW3iC7aWqEXOE)mlqezACmr3pUd3)lInfMgYlg17NzbIitJJj6(XDSn5Aaran6IlTFH8H8qgbWSn4hzgu6cG0cHGrauDCkaQBuaumAJcGolaklIpfSjzd5fJ69Zgb2Q3p0o)i2apVfB29nhyQfrIrHfwvqCj1Qoof1oEoXXr4fMWcRkiUKA3izQBwGgLJzFTqEXOE)S9J7weKlytc6xWPXRvwCai0nWrgPqViZbA8A1Y2KRbeb0Olcu83QUHt)5c31QDrWb6i3e1EWSzv3WP)Cd5fJ69Z2pUdn8rXOE)XPZuOFbNgLMG25hzaP5mQcIlPmlU)xKrccQ1xBFMSjvM0RwCNriyyPxWM0bPqEXOE)S9J7qdFumQ3FC6mf6xWPrZKKfcANFumQVqr6jCNyqLjKxmQ3pB)4o0WhfJ69hNotH(fCAK5p3jbTZpkg1xOi9eUtSXmH8H8Ir9(zwPPXL2ViHgaQE)H8Ir9(zwPP9J7obXzuyg6zE)q78Jyd882L2p(gHBVgWhYlg17NzLM2pUBP9lI1tfANFuLj9Q9eeNXL2pl9c2Ko4UwTSn5Aaran6Iaf)Ticx8NbLIKfAgvhNc5fJ69ZSst7h3Xgqi6pcf1oIl3tmg0o)i2apVDP9JVr4wMkgoHAC9mRThBGN3In7(Mdm1oaesH8Ir9(zwPP9J7obXzCP9dANFej(fPf6vRChZ6puzGziVyuVFMvAA)4oC)pm6pcfYlg17NzLM2pUJTjxdiAqcBdANFej(fPf6vRChZ6puRbhs8lsl0Rw5oM9gqI69ZXSGziVyuVFMvAA)4oC)ViJee0MnX)Xmq7Vsi0aqn64405IsJzG2FLqObGA05hv3WjdQXSGBDt3ZRb82L2Viwpv7aqyH1098AaVf3)lInfMAhacPqEXOE)mR00(XDSn5Aaran6Iaf)d5d5fJ69ZSMjjl04s7xKqdavV)qEXOE)mRzsYcTFC3jioJcZqpZ7hANFeBGN3U0(X3iC71a(qEXOE)mRzsYcTFC3s7xeRNAiVyuVFM1mjzH2pUJTjxdicOrx8ir3GwfexsJo)OkiUKAvhNIAhpN4y2HfwSbEE7s7hFJWTxd4d5fJ69ZSMjjl0(XDSbeI(JqrTJ4Y9eJbTZpInWZBxA)4BeULPIHtOgxpZA7Xg45TyZUV5atTdaHuiVyuVFM1mjzH2pU7eeNXL2pOD(rK4xKwOxTYDmR)qLbMH8Ir9(zwZKKfA)4oC)pm6pcfYlg17NzntswO9J7W9)IytHPH8Ir9(zwZKKfA)4o2MCnGObjSnOD(X1rIFrAHE1k3XS(d1AWHe)I0c9QvUJzVbKOE)CmliblSiXViTqVAL7y2BajQ3puzfYlg17NzntswO9J7yBY1aIaA0fbk(dTbgMjfvbXLu2ygOD(reXJi2MGnj4ubXLuR64uu745euCao4rLj9Qf3zecgw6fSjDWbpQmPxTNG4mU0(zPxWM0fYlg17NzntswO9J7weCGoYnrThmBqBGHzsrvqCjLnMbANFer8iITjytcU1vbXLuR64uu745euWhKc5fJ69ZSMjjl0(XDlcoqh5MO2dMnOnWWmPOkiUKYgZaTZpETAzBY1aIaA0fbk(BrepIyBc2KGBDvM0RwCNriyyPxWM0bNkiUKAvhNIAhpNGIdqkKxmQ3pZAMKSq7h3T0(f1gHOxd5fJ69ZSMjjl0(XD4(FrgjiOvbXL0OZpYasZzufexszwC)ViJeeuzbTzt8Fmd0(RecnauhZeYlg17NzntswO9J7W9)I8tbgqB2e)hZaT)kHqda1OJJtNlknMbA)vcHgaQrNFuDdNmOgZcU1nDpVgWBxA)Iy9uTdaHfwt3ZRb8wC)Vi2uyQDaiKc5fJ69ZSMjjl0(XDSn5Aaran6Iaf)d5d5fJ69ZSm)5oPXL2ViHgaQE)H8Ir9(zwM)CN0(XDNG4mkmd9mVFOD(rSbEE7s7hFJWTxd4d5fJ69ZSm)5oP9J7wA)Iy9ud5fJ69ZSm)5oP9J7yBY1aIaA0fps0nOD(rvqCj1Qoof1oEoXXSdlSMUNxd4TSn5Aaran6Ihj6M1SjiUeBmlyHDDt3ZRb8w2MCnGiGgDXJeDZA2eexInMbot3ZRb8w2MCnGiGgDXJeDZIiCXFgh5AolUa)GuiVyuVFML5p3jTFChBaHO)iuu7iUCpXyq78Jyd882L2p(gHBzQy4eQX1ZS2ESbEEl2S7BoWu7aqibNkiUKAvhNIAhpNGklyctyHvfexsTQJtrTJNtCeYTwiVyuVFML5p3jTFC3jioJlTFq78JiXViTqVAL7yw)Hkdmd5fJ69ZSm)5oP9J7W9)WO)iuiVyuVFML5p3jTFChBtUgqeqJU4rIUbTZpcpyd882L2p(gHBhaclSRB6EEnG3Y2KRbeb0OlEKOBwZMG4sSXSGdBGN3U0(X3iCltfdNCmZAqkKxmQ3pZY8N7K2pUJTjxdiAqcBdANFej(fPf6vRChZ6puRbhs8lsl0Rw5oM9gqI69ZXSGziVyuVFML5p3jTFChU)xeBkmfANFCrqUGnj71kloamKxmQ3pZY8N7K2pUBP9lQncrVcTZpETAzBY1aIaA0fbk(BreU4pdkoa31QDrWb6i3e1EWSzreU4pdkoeYlg17Nzz(ZDs7h3X2KRbeb0Olcu8hANFer8iITjytcovqCj1Qoof1oEobfhGdEuzsVAXDgHGHLEbBshCWJkt6v7jioJlTFw6fSjDH8Ir9(zwM)CN0(XDlcoqh5MO2dMnOD(reXJi2MGnj4ubXLuR64uu745euWhSWUUkt6vlUZiemS0lyt6G7A1Y2KRbeb0Olcu83IiEeX2eSjbPqEXOE)mlZFUtA)4oC)Vi)uGb0MnX)Xmq7Vsi0aqn64405IsJzG2FLqObGA05hv3WjdQXSGBDt3ZRb82L2Viwpv7aqyH1098AaVf3)lInfMAhacPqEXOE)mlZFUtA)4o2MCnGiGgDrGI)LwAva]] )

end
