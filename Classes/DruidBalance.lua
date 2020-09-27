-- DruidBalance.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local PTR = ns.PTR


if UnitClassBase( 'player' ) == 'DRUID' then
    local spec = Hekili:NewSpecialization( 102, true )

    spec:RegisterResource( Enum.PowerType.LunarPower, {
        fury_of_elune = {            
            aura = "fury_of_elune_ap",

            last = function ()
                local app = state.buff.fury_of_elune_ap.applied
                local t = state.query_time

                return app + floor( ( t - app ) / 0.5 ) * 0.5
            end,

            interval = 0.5,
            value = 2.5
        },

        natures_balance = {
            talent = "natures_balance",

            last = function ()
                local app = state.combat
                local t = state.query_time

                return app + floor( ( t - app ) / 1.5 ) * 1.5
            end,

            interval = 1.5, -- actually 0.5 AP every 0.75s, but...
            value = 1,
        }
    } )


    spec:RegisterResource( Enum.PowerType.Mana )
    spec:RegisterResource( Enum.PowerType.Energy )
    spec:RegisterResource( Enum.PowerType.ComboPoints )
    spec:RegisterResource( Enum.PowerType.Rage )


    -- Talents
    spec:RegisterTalents( {
        natures_balance = 22385, -- 202430
        warrior_of_elune = 22386, -- 202425
        force_of_nature = 22387, -- 205636

        tiger_dash = 19283, -- 252216
        renewal = 18570, -- 108238
        wild_charge = 18571, -- 102401

        feral_affinity = 22155, -- 202157
        guardian_affinity = 22157, -- 197491
        restoration_affinity = 22159, -- 197492

        mighty_bash = 21778, -- 5211
        mass_entanglement = 18576, -- 102359
        typhoon = 18577, -- 132469

        soul_of_the_forest = 18580, -- 114107
        starlord = 21706, -- 202345
        incarnation = 21702, -- 102560

        stellar_drift = 22389, -- 202354
        twin_moons = 21712, -- 279620
        stellar_flare = 22165, -- 202347

        shooting_stars = 21648, -- 202342
        fury_of_elune = 21193, -- 202770
        new_moon = 21655, -- 274281
    } )


    -- PvP Talents
    spec:RegisterPvpTalents( { 
        adaptation = 3543, -- 214027
        relentless = 3542, -- 196029
        gladiators_medallion = 3541, -- 208683

        celestial_downpour = 183, -- 200726
        celestial_guardian = 180, -- 233754
        crescent_burn = 182, -- 200567
        cyclone = 857, -- 209753
        deep_roots = 834, -- 233755
        dying_stars = 822, -- 232546
        faerie_swarm = 836, -- 209749
        ironfeather_armor = 1216, -- 233752
        moon_and_stars = 184, -- 233750
        moonkin_aura = 185, -- 209740
        prickling_thorns = 3058, -- 200549
        protector_of_the_grove = 3728, -- 209730
        thorns = 3731, -- 236696
    } )


    spec:RegisterPower( "lively_spirit", 279642, {
        id = 279648,
        duration = 20,
        max_stack = 1,
    } )


    -- Auras
    spec:RegisterAuras( {
        aquatic_form = {
            id = 276012,
        },
        astral_influence = {
            id = 197524,
        },
        barkskin = {
            id = 22812,
            duration = 12,
            max_stack = 1,
        },
        bear_form = {
            id = 5487,
            duration = 3600,
            max_stack = 1,
        },
        blessing_of_cenarius = {
            id = 238026,
            duration = 60,
            max_stack = 1,
        },
        blessing_of_the_ancients = {
            id = 206498,
            duration = 3600,
            max_stack = 1,
        },
        cat_form = {
            id = 768,
            duration = 3600,
            max_stack = 1,
        },
        celestial_alignment = {
            id = 194223,
            duration = 20,
            max_stack = 1,
        },
        dash = {
            id = 1850,
            duration = 10,
            max_stack = 1,
        },
        eclipse = {
            id = 279619,
        },
        empowerments = {
            id = 279708,
        },
        entangling_roots = {
            id = 339,
            duration = 30,
            type = "Magic",
            max_stack = 1,
        },
        feline_swiftness = {
            id = 131768,
        },
        flask_of_the_seventh_demon = {
            id = 188033,
            duration = 3600.006,
            max_stack = 1,
        },
        flight_form = {
            id = 276029,
        },
        force_of_nature = {
            id = 205644,
            duration = 15,
            max_stack = 1,
        },
        frenzied_regeneration = {
            id = 22842,
            duration = 3,
            max_stack = 1,
        },
        fury_of_elune_ap = {
            id = 202770,
            duration = 8,
            max_stack = 1,

            generate = function ()
                local foe = buff.fury_of_elune_ap
                local applied = action.fury_of_elune.lastCast

                if applied and now - applied < 8 then
                    foe.count = 1
                    foe.expires = applied + 8
                    foe.applied = applied
                    foe.caster = "player"
                    return
                end

                foe.count = 0
                foe.expires = 0
                foe.applied = 0
                foe.caster = "nobody"
            end,
        },
        growl = {
            id = 6795,
            duration = 3,
            max_stack = 1,
        },
        incarnation = {
            id = 102560,
            duration = 30,
            max_stack = 1,
            copy = "incarnation_chosen_of_elune"
        },
        ironfur = {
            id = 192081,
            duration = 7,
            max_stack = 1,
        },
        legionfall_commander = {
            id = 233641,
            duration = 3600,
            max_stack = 1,
        },
        lunar_empowerment = {
            id = 164547,
            duration = 45,
            type = "Magic",
            max_stack = 3,
        },
        mana_divining_stone = {
            id = 227723,
            duration = 3600,
            max_stack = 1,
        },
        mass_entanglement = {
            id = 102359,
            duration = 30,
            type = "Magic",
            max_stack = 1,
        },
        mighty_bash = {
            id = 5211,
            duration = 5,
            max_stack = 1,
        },
        moonfire = {
            id = 164812,
            duration = 22,
            tick_time = function () return 2 * haste end,
            type = "Magic",
            max_stack = 1,
        },
        moonkin_form = {
            id = 24858,
            duration = 3600,
            max_stack = 1,
        },
        prowl = {
            id = 5215,
            duration = 3600,
            max_stack = 1,
        },
        regrowth = {
            id = 8936,
            duration = 12,
            type = "Magic",
            max_stack = 1,
        },
        shadowmeld = {
            id = 58984,
            duration = 3600,
            max_stack = 1,
        },
        sign_of_the_critter = {
            id = 186406,
            duration = 3600,
            max_stack = 1,
        },
        solar_beam = {
            id = 81261,
            duration = 3600,
            max_stack = 1,
        },
        solar_empowerment = {
            id = 164545,
            duration = 45,
            type = "Magic",
            max_stack = 3,
        },
        stag_form = {
            id = 210053,
            duration = 3600,
            max_stack = 1,
            generate = function ()
                local form = GetShapeshiftForm()
                local stag = form and form > 0 and select( 4, GetShapeshiftFormInfo( form ) )

                local sf = buff.stag_form

                if stag == 210053 then
                    sf.count = 1
                    sf.applied = now
                    sf.expires = now + 3600
                    sf.caster = "player"
                    return
                end

                sf.count = 0
                sf.applied = 0
                sf.expires = 0
                sf.caster = "nobody"
            end,
        },
        starfall = {
            id = 191034,
            duration = function () return pvptalent.celestial_downpour.enabled and 16 or 8 end,
            max_stack = 1,

            generate = function ()
                local sf = buff.starfall

                if now - action.starfall.lastCast < 8 then
                    sf.count = 1
                    sf.applied = action.starfall.lastCast
                    sf.expires = sf.applied + 8
                    sf.caster = "player"
                    return
                end

                sf.count = 0
                sf.applied = 0
                sf.expires = 0
                sf.caster = "nobody"
            end
        },
        starlord = {
            id = 279709,
            duration = 20,
            max_stack = 3,
        },
        stellar_drift = {
            id = 202461,
            duration = 3600,
            max_stack = 1,
        },
        stellar_flare = {
            id = 202347,
            duration = 24,
            tick_time = function () return 2 * haste end,
            type = "Magic",
            max_stack = 1,
        },
        sunfire = {
            id = 164815,
            duration = 18,
            tick_time = function () return 2 * haste end,
            type = "Magic",
            max_stack = 1,
        },
        thick_hide = {
            id = 16931,
        },
        thorny_entanglement = {
            id = 241750,
            duration = 15,
            max_stack = 1,
        },
        thrash_bear = {
            id = 192090,
            duration = 15,
            max_stack = 3,
        },
        thrash_cat ={
            id = 106830, 
            duration = function()
                local x = 15 -- Base duration
                return talent.jagged_wounds.enabled and x * 0.80 or x
            end,
            tick_time = function()
                local x = 3 -- Base tick time
                return talent.jagged_wounds.enabled and x * 0.80 or x
            end,
        },
        --[[ thrash = {
            id = function ()
                if buff.cat_form.up then return 106830 end
                return 192090
            end,
            duration = function()
                local x = 15 -- Base duration
                return talent.jagged_wounds.enabled and x * 0.80 or x
            end,
            tick_time = function()
                local x = 3 -- Base tick time
                return talent.jagged_wounds.enabled and x * 0.80 or x
            end,
        }, ]]
        tiger_dash = {
            id = 252216,
            duration = 5,
            max_stack = 1,
        },
        travel_form = {
            id = 783,
            duration = 3600,
            max_stack = 1,
        },
        treant_form = {
            id = 114282,
            duration = 3600,
            max_stack = 1,
        },
        typhoon = {
            id = 61391,
            duration = 6,
            type = "Magic",
            max_stack = 1,
        },
        warrior_of_elune = {
            id = 202425,
            duration = 3600,
            type = "Magic",
            max_stack = 3,
        },
        wild_charge = {
            id = 102401,
        },
        yseras_gift = {
            id = 145108,
        },
        -- Alias for Celestial Alignment vs. Incarnation
        ca_inc = {
            alias = { "celestial_alignment", "incarnation" },
            aliasMode = "first", -- use duration info from the first buff that's up, as they should all be equal.
            aliasType = "buff",
            duration = function () return talent.incarnation.enabled and 30 or 20 end,
        },


        -- PvP Talents
        celestial_guardian = {
            id = 234081,
            duration = 3600,
            max_stack = 1,
        },

        cyclone = {
            id = 209753,
            duration = 6,
            max_stack = 1,
        },

        faerie_swarm = {
            id = 209749,
            duration = 5,
            type = "Magic",
            max_stack = 1,
        },

        moon_and_stars = {
            id = 234084,
            duration = 10,
            max_stack = 1,
        },

        moonkin_aura = {
            id = 209746,
            duration = 18,
            type = "Magic",
            max_stack = 3,
        },

        thorns = {
            id = 236696,
            duration = 12,
            type = "Magic",
            max_stack = 1,
        },


        -- Azerite Powers
        arcanic_pulsar = {
            id = 287790,
            duration = 3600,
            max_stack = 9,
        },

        dawning_sun = {
            id = 276153,
            duration = 8,
            max_stack = 1,
        },

        sunblaze = {
            id = 274399,
            duration = 20,
            max_stack = 1
        },
    } )


    spec:RegisterStateFunction( "break_stealth", function ()
        removeBuff( "shadowmeld" )
        if buff.prowl.up then
            setCooldown( "prowl", 6 )
            removeBuff( "prowl" )
        end
    end )


    -- Function to remove any form currently active.
    spec:RegisterStateFunction( "unshift", function()
        removeBuff( "cat_form" )
        removeBuff( "bear_form" )
        removeBuff( "travel_form" )
        removeBuff( "moonkin_form" )
        removeBuff( "travel_form" )
        removeBuff( "aquatic_form" )
        removeBuff( "stag_form" )
        removeBuff( "celestial_guardian" )
    end )


    -- Function to apply form that is passed into it via string.
    spec:RegisterStateFunction( "shift", function( form )
        removeBuff( "cat_form" )
        removeBuff( "bear_form" )
        removeBuff( "travel_form" )
        removeBuff( "moonkin_form" )
        removeBuff( "travel_form" )
        removeBuff( "aquatic_form" )
        removeBuff( "stag_form" )
        applyBuff( form )

        if form == "bear_form" and pvptalent.celestial_guardian.enabled then
            applyBuff( "celestial_guardian" )
        end
    end )


    spec:RegisterHook( "runHandler", function( ability )
        local a = class.abilities[ ability ]

        if not a or a.startsCombat then
            break_stealth()
        end 
    end )

    spec:RegisterHook( "pregain", function( amt, resource, overcap, clean )
        if buff.memory_of_lucid_dreams.up then
            if amt > 0 and resource == "astral_power" then
                return amt * 2, resource, overcap, true
            end
        end
    end )

    spec:RegisterHook( "prespend", function( amt, resource, clean )
        if buff.memory_of_lucid_dreams.up then
            if amt < 0 and resource == "astral_power" then
                return amt * 2, resource, overcap, true
            end
        end
    end )


    local check_for_ap_overcap = setfenv( function( ability )
        local a = ability or this_action
        if not a then return true end

        a = action[ a ]
        if not a then return true end

        local cost = 0
        if a.spendType == "astral_power" then cost = a.cost end

        return astral_power.current - cost + ( talent.shooting_stars.enabled and 4 or 0 ) + ( talent.natures_balance.enabled and ceil( execute_time / 1.5 ) or 0 ) < astral_power.max
    end, state )

    spec:RegisterStateExpr( "ap_check", function() return check_for_ap_overcap() end )
    
    -- Simplify lookups for AP abilities consistent with SimC.
    local ap_checks = { 
        "force_of_nature", "full_moon", "half_moon", "incarnation", "lunar_strike", "moonfire", "new_moon", "solar_wrath", "starfall", "starsurge", "sunfire"
    }

    for i, lookup in ipairs( ap_checks ) do
        spec:RegisterStateExpr( lookup, function ()
            return action[ lookup ]
        end )
    end
    

    spec:RegisterStateExpr( "active_moon", function ()
        return "new_moon"
    end )

    local function IsActiveSpell( id )
        local slot = FindSpellBookSlotBySpellID( id )
        if not slot then return false end

        local _, _, spellID = GetSpellBookItemName( slot, "spell" )
        return id == spellID 
    end

    state.IsActiveSpell = IsActiveSpell

    spec:RegisterHook( "reset_precast", function ()
        if IsActiveSpell( class.abilities.new_moon.id ) then active_moon = "new_moon"
        elseif IsActiveSpell( class.abilities.half_moon.id ) then active_moon = "half_moon"
        elseif IsActiveSpell( class.abilities.full_moon.id ) then active_moon = "full_moon"
        else active_moon = nil end

        -- UGLY
        if talent.incarnation.enabled then
            rawset( cooldown, "ca_inc", cooldown.incarnation )
        else
            rawset( cooldown, "ca_inc", cooldown.celestial_alignment )
        end

        if buff.warrior_of_elune.up then
            setCooldown( "warrior_of_elune", 3600 ) 
        end
    end )


    spec:RegisterHook( "spend", function( amt, resource )
        if level < 116 and equipped.impeccable_fel_essence and resource == "astral_power" and cooldown.celestial_alignment.remains > 0 then
            setCooldown( "celestial_alignment", max( 0, cooldown.celestial_alignment.remains - ( amt / 12 ) ) )
        end 
    end )


    -- Legion Sets (for now).
    spec:RegisterGear( 'tier21', 152127, 152129, 152125, 152124, 152126, 152128 )
        spec:RegisterAura( 'solar_solstice', {
            id = 252767,
            duration = 6,
            max_stack = 1,
         } ) 

    spec:RegisterGear( 'tier20', 147136, 147138, 147134, 147133, 147135, 147137 )
    spec:RegisterGear( 'tier19', 138330, 138336, 138366, 138324, 138327, 138333 )
    spec:RegisterGear( 'class', 139726, 139728, 139723, 139730, 139725, 139729, 139727, 139724 )

    spec:RegisterGear( "impeccable_fel_essence", 137039 )    
    spec:RegisterGear( "oneths_intuition", 137092 )
        spec:RegisterAuras( {
            oneths_intuition = {
                id = 209406,
                duration = 3600,
                max_stacks = 1,
            },    
            oneths_overconfidence = {
                id = 209407,
                duration = 3600,
                max_stacks = 1,
            },
        } )

    spec:RegisterGear( "radiant_moonlight", 151800 )
    spec:RegisterGear( "the_emerald_dreamcatcher", 137062 )
        spec:RegisterAura( "the_emerald_dreamcatcher", {
            id = 224706,
            duration = 5,
            max_stack = 2,
        } )



    -- Abilities
    spec:RegisterAbilities( {
        barkskin = {
            id = 22812,
            cast = 0,
            cooldown = 60,
            gcd = "off",

            toggle = "defensives",
            defensive = true,

            startsCombat = false,
            texture = 136097,

            handler = function ()
                applyBuff( "barkskin" )
            end,
        },


        bear_form = {
            id = 5487,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = -25,
            spendType = "rage",

            startsCombat = false,
            texture = 132276,

            noform = "bear_form",

            handler = function ()
                shift( "bear_form" )
            end,
        },


        cat_form = {
            id = 768,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = false,
            texture = 132115,

            noform = "cat_form",

            handler = function ()
                shift( "cat_form" )
            end,
        },


        celestial_alignment = {
            id = 194223,
            cast = 0,
            cooldown = function () return ( essence.vision_of_perfection.enabled and 0.85 or 1 ) * 180 end,
            gcd = "spell",

            toggle = "cooldowns",

            startsCombat = true,
            texture = 136060,

            notalent = "incarnation",

            handler = function ()
                applyBuff( "celestial_alignment" )
                gain( 40, "astral_power" )
                if pvptalent.moon_and_stars.enabled then applyBuff( "moon_and_stars" ) end
            end,

            copy = "ca_inc"
        },


        cyclone = {
            id = 209753,
            cast = 1.7,
            cooldown = 0,
            gcd = "spell",

            pvptalent = "cyclone",

            spend = 0.15,
            spendType = "mana",

            startsCombat = true,
            texture = 136022,

            handler = function ()
                applyDebuff( "target", "cyclone" )
            end,
        },


        dash = {
            id = 1850,
            cast = 0,
            cooldown = 120,
            gcd = "off",

            startsCombat = false,
            texture = 132120,

            notalent = "tiger_dash",

            handler = function ()
                if not buff.cat_form.up then
                    shift( "cat_form" )
                end
                applyBuff( "dash" )
            end,
        },


        --[[ dreamwalk = {
            id = 193753,
            cast = 10,
            cooldown = 60,
            gcd = "spell",

            spend = 4,
            spendType = "mana",

            toggle = "cooldowns",

            startsCombat = true,
            texture = 135763,

            handler = function ()
            end,
        }, ]]


        entangling_roots = {
            id = 339,
            cast = 1.7,
            cooldown = 0,
            gcd = "spell",

            spend = 0.18,
            spendType = "mana",

            startsCombat = false,
            texture = 136100,

            handler = function ()
                applyDebuff( "target", "entangling_roots" )
            end,
        },


        faerie_swarm = {
            id = 209749,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            pvptalent = "faerie_swarm",

            startsCombat = true,
            texture = 538516,

            handler = function ()
                applyDebuff( "target", "faerie_swarm" )
            end,
        },


        ferocious_bite = {
            id = 22568,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 50,
            spendType = "energy",

            startsCombat = true,
            texture = 132127,

            form = "cat_form",
            talent = "feral_affinity",

            usable = function () return combo_points.current > 0 end,
            handler = function ()
                --[[ if target.health.pct < 25 and debuff.rip.up then
                    applyDebuff( "target", "rip", min( debuff.rip.duration * 1.3, debuff.rip.remains + debuff.rip.duration ) )
                end ]]
                spend( combo_points.current, "combo_points" )
            end,
        },


        --[[ flap = {
            id = 164862,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = true,
            texture = 132925,

            handler = function ()
            end,
        }, ]]


        force_of_nature = {
            id = 205636,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            spend = -20,
            spendType = "astral_power",

            toggle = "cooldowns",

            startsCombat = true,
            texture = 132129,

            talent = "force_of_nature",

            ap_check = function() return check_for_ap_overcap( "force_of_nature" ) end,

            handler = function ()
                summonPet( "treants", 10 )
            end,
        },


        frenzied_regeneration = {
            id = 22842,
            cast = 0,
            charges = 1,
            cooldown = 36,
            recharge = 36,
            gcd = "spell",

            spend = 10,
            spendType = "rage",

            startsCombat = false,
            texture = 132091,

            form = "bear_form",
            talent = "guardian_affinity",

            handler = function ()
                applyBuff( "frenzied_regeneration" )
                gain( 0.08 * health.max, "health" )
            end,
        },


        full_moon = {
            id = 274283,
            known = 274281,
            cast = 3,
            charges = 3,
            cooldown = 25,
            recharge = 25,
            gcd = "spell",

            spend = -40,
            spendType = "astral_power",

            texture = 1392542,
            startsCombat = true,

            talent = "new_moon",
            bind = "half_moon",

            ap_check = function() return check_for_ap_overcap( "full_moon" ) end,

            usable = function () return active_moon == "full_moon" end,
            handler = function ()
                spendCharges( "new_moon", 1 )
                spendCharges( "half_moon", 1 )

                -- Radiant Moonlight, NYI.
                active_moon = "new_moon"
            end,
        },


        fury_of_elune = {
            id = 202770,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            -- toggle = "cooldowns",

            startsCombat = true,
            texture = 132123,

            handler = function ()
                if not buff.moonkin_form.up then unshift() end
                applyDebuff( "target", "fury_of_elune_ap" )
            end,
        },


        growl = {
            id = 6795,
            cast = 0,
            cooldown = 8,
            gcd = "off",

            startsCombat = true,
            texture = 132270,

            form = "bear_form",

            handler = function ()
                applyDebuff( "target", "growl" )
            end,
        },


        half_moon = {
            id = 274282, 
            known = 274281,
            cast = 2,
            charges = 3,
            cooldown = 25,
            recharge = 25,
            gcd = "spell",

            spend = -20,
            spendType = "astral_power",

            texture = 1392543,
            startsCombat = true,

            talent = "new_moon",
            bind = "new_moon",

            ap_check = function() return check_for_ap_overcap( "half_moon" ) end,

            usable = function () return active_moon == 'half_moon' end,
            handler = function ()
                spendCharges( "new_moon", 1 )
                spendCharges( "full_moon", 1 )

                active_moon = "full_moon"
            end,
        },


        hibernate = {
            id = 2637,
            cast = 1.5,
            cooldown = 0,
            gcd = "spell",

            spend = 0.15,
            spendType = "mana",

            startsCombat = false,
            texture = 136090,

            handler = function ()
                applyDebuff( "target", "hibernate" )
            end,
        },


        incarnation = {
            id = 102560,
            cast = 0,
            cooldown = function () return ( essence.vision_of_perfection.enabled and 0.85 or 1 ) * 180 end,
            gcd = "spell",

            spend = -40,
            spendType = "astral_power",

            toggle = "cooldowns",

            startsCombat = false,
            texture = 571586,

            talent = "incarnation",

            handler = function ()
                shift( "moonkin_form" )
                
                applyBuff( "incarnation" )

                if pvptalent.moon_and_stars.enabled then applyBuff( "moon_and_stars" ) end
            end,

            copy = { "incarnation_chosen_of_elune", "Incarnation" },
        },


        innervate = {
            id = 29166,
            cast = 0,
            cooldown = 180,
            gcd = "spell",

            toggle = "cooldowns",

            startsCombat = false,
            texture = 136048,

            usable = function () return group end,
            handler = function ()
                active_dot.innervate = 1
            end,
        },


        ironfur = {
            id = 192081,
            cast = 0,
            cooldown = 0.5,
            gcd = "spell",

            spend = 45,
            spendType = "rage",

            startsCombat = true,
            texture = 1378702,

            handler = function ()
                applyBuff( "ironfur" )
            end,
        },


        lunar_strike = {
            id = 194153,
            cast = function () 
                if buff.warrior_of_elune.up then return 0 end
                return haste * ( buff.lunar_empowerment.up and 0.85 or 1 ) * 2.25 
            end,
            cooldown = 0,
            gcd = "spell",

            spend = function () return ( buff.warrior_of_elune.up and 1.4 or 1 ) * -12 end,
            spendType = "astral_power",

            startsCombat = true,
            texture = 135753,            

            ap_check = function() return check_for_ap_overcap( "lunar_strike" ) end,

            handler = function ()
                if not buff.moonkin_form.up then unshift() end
                removeStack( "lunar_empowerment" )

                if buff.warrior_of_elune.up then
                    removeStack( "warrior_of_elune" )
                    if buff.warrior_of_elune.down then
                        setCooldown( "warrior_of_elune", 45 ) 
                    end
                end

                if azerite.dawning_sun.enabled then applyBuff( "dawning_sun" ) end
            end,
        },


        mangle = {
            id = 33917,
            cast = 0,
            cooldown = 6,
            gcd = "spell",

            spend = -10,
            spendType = "rage",

            startsCombat = true,
            texture = 132135,

            talent = "guardian_affinity",
            form = "bear_form",

            handler = function ()
            end,
        },


        mass_entanglement = {
            id = 102359,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            startsCombat = false,
            texture = 538515,

            talent = "mass_entanglement",

            handler = function ()
                applyDebuff( "target", "mass_entanglement" )
                active_dot.mass_entanglement = max( active_dot.mass_entanglement, active_enemies )
            end,
        },


        mighty_bash = {
            id = 5211,
            cast = 0,
            cooldown = 50,
            gcd = "spell",

            startsCombat = true,
            texture = 132114,

            talent = "mighty_bash",

            handler = function ()
                applyDebuff( "target", "mighty_bash" )
            end,
        },


        moonfire = {
            id = 8921,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = -3,
            spendType = "astral_power",

            startsCombat = true,
            texture = 136096,

            cycle = "moonfire",

            ap_check = function() return check_for_ap_overcap( "moonfire" ) end,

            handler = function ()
                if not buff.moonkin_form.up and not buff.bear_form.up then unshift() end
                applyDebuff( "target", "moonfire" )

                if talent.twin_moons.enabled and active_enemies > 1 then
                    active_dot.moonfire = min( active_enemies, active_dot.moonfire + 1 )
                end
            end,
        },


        moonkin_form = {
            id = 24858,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = false,
            texture = 136036,

            noform = "moonkin_form",
            essential = true,

            handler = function ()
                shift( "moonkin_form" )
            end,
        },


        new_moon = {
            id = 274281, 
            cast = 1,
            charges = 3,
            cooldown = 25,
            recharge = 25,
            gcd = "spell",

            spend = -10,
            spendType = "astral_power",

            texture = 1392545,
            startsCombat = true,

            talent = "new_moon",
            bind = "full_moon",

            ap_check = function() return check_for_ap_overcap( "new_moon" ) end,

            usable = function () return active_moon == "new_moon" end,
            handler = function ()
                spendCharges( "half_moon", 1 )
                spendCharges( "full_moon", 1 )

                active_moon = "half_moon"
            end,
        },


        prowl = {
            id = 5215,
            cast = 0,
            cooldown = 6,
            gcd = "spell",

            startsCombat = false,
            texture = 514640,

            usable = function () return time == 0 end,
            handler = function ()
                shift( "cat_form" )
                applyBuff( "prowl" )
                removeBuff( "shadowmeld" )
            end,
        },


        rake = {
            id = 1822,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 35,
            spendType = "energy",

            startsCombat = true,
            texture = 132122,

            talent = "feral_affinity",
            form = "cat_form",

            handler = function ()
                applyDebuff( "target", "rake" )
            end,
        },


        --[[ rebirth = {
            id = 20484,
            cast = 2,
            cooldown = 600,
            gcd = "spell",

            spend = 0,
            spendType = "rage",

            -- toggle = "cooldowns",

            startsCombat = true,
            texture = 136080,

            handler = function ()
            end,
        }, ]]


        regrowth = {
            id = 8936,
            cast = 1.5,
            cooldown = 0,
            gcd = "spell",

            spend = 0.14,
            spendType = "mana",

            startsCombat = false,
            texture = 136085,

            handler = function ()
                if buff.moonkin_form.down then unshift() end
                applyBuff( "regrowth" )
            end,
        },


        rejuvenation = {
            id = 774,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 0.11,
            spendType = "mana",

            startsCombat = false,
            texture = 136081,

            talent = "restoration_affinity",

            handler = function ()
                if buff.moonkin_form.down then unshift() end
                applyBuff( "rejuvenation" )
            end,
        },


        remove_corruption = {
            id = 2782,
            cast = 0,
            cooldown = 8,
            gcd = "spell",

            spend = 0.06,
            spendType = "mana",

            startsCombat = true,
            texture = 135952,

            handler = function ()
            end,
        },


        renewal = {
            id = 108238,
            cast = 0,
            cooldown = 90,
            gcd = "spell",

            startsCombat = true,
            texture = 136059,

            talent = "renewal",

            handler = function ()
                -- unshift?
                gain( 0.3 * health.max, "health" )
            end,
        },


        --[[ revive = {
            id = 50769,
            cast = 10,
            cooldown = 0,
            gcd = "spell",

            spend = 0.04,
            spendType = "mana",

            startsCombat = true,
            texture = 132132,

            handler = function ()
            end,
        }, ]]


        rip = {
            id = 1079,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 30,
            spendType = "energy",

            startsCombat = true,
            texture = 132152,

            talent = "feral_affinity",
            form = "cat_form",

            usable = function () return combo_points.current > 0 end,
            handler = function ()
                spend( combo_points.current, "combo_points" )
                applyDebuff( "target", "rip" )
            end,
        },


        shred = {
            id = 5221,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 40,
            spendType = "energy",

            startsCombat = true,
            texture = 136231,

            talent = "feral_affinity",
            form = "cat_form",

            handler = function ()
                gain( 1, "combo_points" )
            end,
        },


        solar_beam = {
            id = 78675,
            cast = 0,
            cooldown = 60,
            gcd = "off",

            spend = 0.17,
            spendType = "mana",

            toggle = "interrupts",

            startsCombat = true,
            texture = 252188,

            debuff = "casting",
            readyTime = state.timeToInterrupt,

            handler = function ()
                if buff.moonkin_form.down then unshift() end
                interrupt()
            end,
        },


        solar_wrath = {
            id = 190984,
            cast = function () return haste * ( buff.solar_empowerment.up and 0.85 or 1 ) * 1.5 end,
            cooldown = 0,
            gcd = "spell",

            spend = -8,
            spendType = "astral_power",

            startsCombat = true,
            texture = 535045,

            ap_check = function() return check_for_ap_overcap( "solar_wrath" ) end,

            handler = function ()
                if not buff.moonkin_form.up then unshift() end
                removeStack( "solar_empowerment" )
                removeBuff( "dawning_sun" )
                if azerite.sunblaze.enabled then applyBuff( "sunblaze" ) end
            end,
        },


        soothe = {
            id = 2908,
            cast = 0,
            cooldown = 10,
            gcd = "spell",

            spend = 0.06,
            spendType = "mana",

            startsCombat = true,
            texture = 132163,

            usable = function () return buff.dispellable_enrage.up end,
            handler = function ()
                if buff.moonkin_form.down then unshift() end
                removeBuff( "dispellable_enrage" )
            end,
        },


        stag_form = {
            id = 210053,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = false,
            texture = 1394966,

            noform = "travel_form",
            handler = function ()
                shift( "stag_form" )
            end,
        },


        starfall = {
            id = 191034,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function ()
                if buff.oneths_overconfidence.up then return 0 end
                return talent.soul_of_the_forest.enabled and 40 or 50
            end,
            spendType = "astral_power",

            startsCombat = true,
            texture = 236168,

            ap_check = function() return check_for_ap_overcap( "starfall" ) end,

            handler = function ()
                addStack( "starlord", buff.starlord.remains > 0 and buff.starlord.remains or nil, 1 )
                removeBuff( "oneths_overconfidence" )
                if level < 116 and set_bonus.tier21_4pc == 1 then
                    applyBuff( "solar_solstice" )
                end
            end,
        },


        starsurge = {
            id = 78674,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function ()
                if buff.oneths_intuition.up then return 0 end
                return 40 - ( buff.the_emerald_dreamcatcher.stack * 5 )
            end,
            spendType = "astral_power",

            startsCombat = true,
            texture = 135730,

            ap_check = function() return check_for_ap_overcap( "starsurge" ) end,   

            handler = function ()
                addStack( "lunar_empowerment", nil, 1 )
                addStack( "solar_empowerment", nil, 1 )
                addStack( "starlord", buff.starlord.remains > 0 and buff.starlord.remains or nil, 1 )
                removeBuff( "oneths_intuition" )
                removeBuff( "sunblaze" )

                if pvptalent.moonkin_aura.enabled then
                    addStack( "moonkin_aura", nil, 1 )
                end

                if level < 116 and set_bonus.tier21_4pc == 1 then
                    applyBuff( "solar_solstice" )
                end

                if azerite.arcanic_pulsar.enabled then
                    addStack( "arcanic_pulsar" )
                    if buff.arcanic_pulsar.stack == 9 then
                        removeBuff( "arcanic_pulsar" )
                        applyBuff( talent.incarnation.enabled and "incarnation" or "celestial_alignment" )
                    end
                end

                if ( level < 116 and equipped.the_emerald_dreamcatcher ) then addStack( "the_emerald_dreamcatcher", 5, 1 ) end
            end,
        },


        stellar_flare = {
            id = 202347,
            cast = 1.5,
            cooldown = 0,
            gcd = "spell",

            spend = -8,
            spendType = "astral_power",

            startsCombat = true,
            texture = 1052602,
            cycle = "stellar_flare",

            talent = "stellar_flare",

            ap_check = function() return check_for_ap_overcap( "stellar_flare" ) end,

            handler = function ()
                applyDebuff( "target", "stellar_flare" )
            end,
        },


        sunfire = {
            id = 93402,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = -3,
            spendType = "astral_power",

            startsCombat = true,
            texture = 236216,

            cycle = "sunfire",

            ap_check = function()
                return astral_power.current - action.sunfire.cost + ( talent.shooting_stars.enabled and 4 or 0 ) + ( talent.natures_balance.enabled and ceil( execute_time / 1.5 ) or 0 ) < astral_power.max
            end,            

            readyTime = function()
                return mana[ "time_to_" .. ( 0.12 * mana.max ) ]
            end,

            handler = function ()
                spend( 0.12 * mana.max, "mana" ) -- I want to see AP in mouseovers.
                applyDebuff( "target", "sunfire" )
                active_dot.sunfire = active_enemies
            end,
        },


        swiftmend = {
            id = 18562,
            cast = 0,
            charges = 1,
            cooldown = 25,
            recharge = 25,
            gcd = "spell",

            spend = 0.14,
            spendType = "mana",

            startsCombat = false,
            texture = 134914,

            talent = "restoration_affinity",            

            handler = function ()
                if buff.moonkin_form.down then unshift() end
                gain( health.max * 0.1, "health" )
            end,
        },

        -- May want to revisit this and split out swipe_cat from swipe_bear.
        swipe_bear = {
            known = 213764,
            cast = 0,
            cooldown = function () return haste * ( buff.cat_form.up and 0 or 6 ) end,
            gcd = "spell",

            spend = function () return buff.cat_form.up and 40 or nil end,
            spendType = function () return buff.cat_form.up and "energy" or nil end,

            startsCombat = true,
            texture = 134296,

            talent = "feral_affinity",

            usable = function () return buff.cat_form.up or buff.bear_form.up end,
            handler = function ()
                if buff.cat_form.up then
                    gain( 1, "combo_points" )
                end
            end,

            copy = { "swipe", 106785, 213771 },
            bind = { "swipe", "swipe_bear", "swipe_cat" }
        },


        thrash_bear = {
            id = 106832,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = -5,
            spendType = "rage",

            cycle = "thrash_bear",
            startsCombat = true,
            texture = 451161,

            talent = "guardian_affinity",
            form = "bear_form",

            handler = function ()
                applyDebuff( "target", "thrash_bear", nil, debuff.thrash.stack + 1 )
            end,

            copy = { "thrash", 106832 },
            bind = { "thrash", "thrash_bear", "thrash_cat" }
        },


        tiger_dash = {
            id = 252216,
            cast = 0,
            cooldown = 45,
            gcd = "off",

            startsCombat = false,
            texture = 1817485,

            talent = "tiger_dash",

            handler = function ()
                shift( "cat_form" )
                applyBuff( "tiger_dash" )
            end,
        },


        thorns = {
            id = 236696,
            cast = 0,
            cooldown = 45,
            gcd = "spell",

            pvptalent = function ()
                if essence.conflict_and_strife.enabled then return end
                return "thorns"
            end,

            spend = 0.12,
            spendType = "mana",

            startsCombat = false,
            texture = 136104,

            handler = function ()
                applyBuff( "thorns" )
            end,
        },


        travel_form = {
            id = 783,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = false,
            texture = 132144,

            noform = "travel_form",
            handler = function ()
                shift( "travel_form" )
            end,
        },


        treant_form = {
            id = 114282,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = false,
            texture = 132145,

            handler = function ()
                shift( "treant_form" )
            end,
        },


        typhoon = {
            id = 132469,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            startsCombat = true,
            texture = 236170,

            talent = "typhoon",

            handler = function ()
                applyDebuff( "target", "typhoon" )
                if target.distance < 15 then setDistance( target.distance + 5 ) end
            end,
        },


        warrior_of_elune = {
            id = 202425,
            cast = 0,
            cooldown = 45,
            gcd = "spell",

            startsCombat = true,
            texture = 135900,

            talent = "warrior_of_elune",

            usable = function () return buff.warrior_of_elune.down end,
            handler = function ()
                applyBuff( "warrior_of_elune", nil, 3 )
            end,
        },


        --[[ wartime_ability = {
            id = 264739,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = true,
            texture = 1518639,

            handler = function ()
            end,
        }, ]]


        wild_charge = {
            id = function () return buff.moonkin_form.up and 102383 or 102401 end,
            known = 102401,
            cast = 0,
            cooldown = 15,
            gcd = "spell",

            startsCombat = false,
            texture = 538771,

            talent = "wild_charge",

            handler = function ()
                if buff.moonkin_form.up then setDistance( target.distance + 10 ) end
            end,

            copy = { 102401, 102383 }
        },


        wild_growth = {
            id = 48438,
            cast = 1.5,
            cooldown = 10,
            gcd = "spell",

            spend = 0.3,
            spendType = "mana",

            startsCombat = false,
            texture = 236153,

            talent = "wild_growth",

            handler = function ()
                unshift()
                applyBuff( "wild_growth" )
            end,
        },
    } )

    spec:RegisterOptions( {
        enabled = true,

        aoe = 3,

        nameplates = false,
        nameplateRange = 8,

        damage = true,
        damageDots = false,
        damageExpiration = 6,

        potion = "unbridled_fury",

        package = "Balance",        
    } )

    
    spec:RegisterSetting( "starlord_cancel", false, {
        name = "Cancel |T462651:0|t Starlord",
        desc = "If checked, the addon will recommend canceling your Starlord buff before starting to build stacks with Starsurge again.\n\n" ..
            "You will likely want a |cFFFFD100/cancelaura Starlord|r macro to manage this during combat.",
        icon = 462651,
        iconCoords = { 0.1, 0.9, 0.1, 0.9 },
        type = "toggle",
        width = 1.5
    } )

    -- Starlord Cancel Override
    class.specs[0].abilities.cancel_buff.funcs.usable = setfenv( function ()
        if not settings.starlord_cancel and args.buff_name == "starlord" then return false, "starlord cancel option disabled" end
        return args.buff_name ~= nil, "no buff name detected"
    end, state )    


    spec:RegisterPack( "Balance", 20200614, [[dC0x5aqiPkpcPuxsQkAtiPprPs1OKIoLuXQaI6vuQAwusULuvQDHQFrjAyaHJrj1YOu8mKctdiY1qkPTrPs(gLkW4KQcNJsfADiLG3HuI08qk6Eiv7JsPdsPIAHsHEiLkYePubDrKseBKsLs9rkvk5KiLOwPuPzIuczNcQwksjupfQMQuWEPYFfAWQ6WelgLEmIjJIltAZu1NbQrliNwPvtPsXRrIztXTHYUv53qgUalxYZbnDrxhW2bsFNsy8svjNxqz9sv18Ls7xXoRDn4WzKuDHBdiSbeGWUSgK4wBdibs0WAhEgwG6WdecfbS6WpbtD4nkg5iQdpqcZGegxdoCicOiQdpuMbqAblTe8MHay5eeMLWfdWi5Iosj(0s4IrS0HZcSMKw(CSoCgjvx42acBabiSlRbjU12asGKnGKdxaYqOYHJVy2jhEOLHrphRdNrHehoTNVrXihrN3oSawMPlTNpuMbqAblTe8MHay5eeMLWfdWi5Iosj(0s4IrSC6s757cC68wdswnVnGWgqmDNU0EE7ui5aRqAHPlTNVVN3oZWOmZJJmsnFJQGXNU0E((EE7ui5aRmZNsbwZ46NNiqfoFIMNegXOXukWAc5txApFFpp(IfywFyZBN7xRn15Zs2CEdcrbiaoFtg0z3Z5bG68a3PefcLkS5bvQvyn68WWUu6Ro8PlTNVVNNwSIHavzMNw0cQAcBE8GT2CEc6y2Cr38EunVDsnkmxXmVD2SGpm9sAPZhgcWUBmZhsavNFZ5r18HHaM3c0z3Z5H7r05PLVtlqLuNFHZhAbhsR5dQfvBgg3HBwycDn4WzuVaysxdUWT21Gdxi5IohoezKkYQcMdxpH1OmUgDPlCBCn4W1tynkJRrhoP2uRvC4SaEpNiX9iCGahUqYfDoCwTGArzpWU0fonCn4W1tynkJRrhUqYfDoCPFyiPey0JUmI8XaKfA5Wj1MATIdV38SaEpNiX9iCGG5Popdk5yi053s55sOSh45Popdk5qGZVLYZLqzpWZtD(MZ3B(um6LCyQgJurVrkLRNWAuM5BBNNbLCyQgJurVrkLNlHYEGNVJd)em1Hl9ddjLaJE0LrKpgGSqlx6chKCn4W1tynkJRrhoP2uRvC4nNV38Py0l5WukdQy46jSgLz(225zb8EomLYGkgoqW8DMN689MNfW75ejUhHdemp15zqjhdHo)wkpxcL9app15zqjhcC(TuEUek7bEEQZ3C(EZNIrVKdt1yKk6nsPC9ewJYmFB78mOKdt1yKk6nsP8Cju2d88DC4cjx05WbdifZkxe5Js)AHYqU0foT6AWHRNWAugxJoCHKl6C4KWiguwOBjrwJathoP2uRvC49MNfW75ejUhHdemp15zqjhdHo)wkpxcL9app15zqjhcC(TuEUek7bEEQZ3C(EZNIrVKdt1yKk6nsPC9ewJYmFB78mOKdt1yKk6nsP8Cju2d88DC4Q3RKmEcM6WjHrmOSq3sISgbMU0fUD5AWHRNWAugxJoCHKl6C4WqlOAfbvpewSuZsC4NGPoCyOfuTIGQhclwQzjoCsTPwR4W7nplG3ZjsCpchiyEQZ3BEwaVNZAqigdam5abo8ukWAgxVdNbLCyOfuTIGQhcJdtHqzEBPppT6sx42bUgC46jSgLX1Odxi5IohoMCRxHjkI8rmH5ui0HtQn1AfholG3ZjsCpcVumzp482oV1Gy(225zb8EorI7r4LIj7bN325bP5PoplG3ZLIi3sIbagOuCykekZB78218TTZ7xWHYyPyYEW5P582yTd)em1HJj36vyIIiFetyofcDPl8(W1GdxpH1OmUgD4KAtTwXHtqiddYIJtK4EeEPyYEW5TDEAachUqYfDoCwdcXer(ygsJ6PyH5sx42rxdoC9ewJY4A0HtQn1AfhEV5zb8EorI7r4abZtD(MZlWSetmazHwZtZ5THwNVTDEcczyqwCCIe3JWlft2doVTZtdqmFN5Popdk5qGZVLYlft2doVTZBniMN68mOKJHqNFlLxkMShCEBN3Aqmp15BoFV5tXOxYHPAmsf9gPuUEcRrzMVTDEguYHPAmsf9gPuEPyYEW5TDERbX8DC4cjx05WXumufwe5JgaYYezkvWGU0fU1GW1Gdxi5IohEaqT(W2dCK1iW0HRNWAugxJU0fU1w7AWHlKCrNdV2GaJg3lcdeI6W1tynkJRrx6c3ABCn4WfsUOZHtqhrVSKuzIEJGPoC9ewJY4A0LUWTMgUgC46jSgLX1OdNuBQ1koCwaVNxkHIrHWOhveLdemp15zqjhdHo)wkpxcL9app15zqjhcC(TuEUek7bEEQZ3C(EZNIrVKdt1yKk6nsPC9ewJYmFB78mOKdt1yKk6nsP8Cju2d88DC4cjx05WZqAe4yraht0JkI6sx4wdsUgC4cjx05WTavggq19ILcrNCe1HRNWAugxJU0fU10QRbhUEcRrzCn6Wj1MATIdV589MhuPwH1OCP)ieoFB789MNfW75ejUhHdemFN5Popdk5yi053s55sOSh45Popdk5qGZVLYZLqzpWZtD(MZ3B(um6LCyQgJurVrkLRNWAuM5BBNNbLCyQgJurVrkLNlHYEGNVJdxi5IohUhraGktu6xRn1iRkyU0fU12LRbhUqYfDo8meQoOdxpH1OmUgDPlCRTdCn4W1tynkJRrhoP2uRvC4SaEpNiX9iCGG5BBN3VGdLXsXK9GZtZ5TbeoCHKl6C4aqnUPIbDPlCR7dxdoCHKl6C4wivTOkI8r1aCQdxpH1OmUgDPlCRTJUgC46jSgLX1OdNuBQ1ko8EZZc49CIe3JWbcMN68nNNfW75ykgQclI8rdazzImLkyqoqW8TTZ3C(MZtqiddYIJJPyOkSiYhnaKLjYuQGb5LIj7bN325TbeZ32oFV5viupIYXumufwe5JgaYYezkvWGCmXUbvZ3zEQZlbrsiLqz(oZ3zEQZ3CEwaVNJPyOkSiYhnaKLjYuQGb5abZ32oVeejHucL57mp15zqjhcC(TuEPyYEW5TD((yEQZZGsogcD(TuEPyYEW5TDERTzEQZ3CEguYHPAmsf9gPuEPyYEW5TDE7A(2257nFkg9somvJrQO3iLY1tynkZ8DC4cjx05W3Ji1j5Iox6c3gq4AWHRNWAugxJoCsTPwR4W7nplG3ZjsCpchiyEQZ3CEwaVNJPyOkSiYhnaKLjYuQGb5abZ32oFZ5BopbHmmilooMIHQWIiF0aqwMitPcgKxkMShCEBN3gqmFB789MxHq9ikhtXqvyrKpAailtKPubdYXe7gunFN5PoVeejHucL57mFN5PoFZ5zqjhcC(TuEPyYEW5TDEBMN68mOKJHqNFlLNlHYEGNN68nNNbLCyQgJurVrkLNlHYEGNVTD(EZNIrVKdt1yKk6nsPC9ewJYmFN574WfsUOZHtuJcZvmrXSGpm9sx6c3gRDn4W1tynkJRrhoP2uRvC4nNNfW75ejUhHdemFB78eeYWGS44ejUhHxkMShCEBNNgGy(oZtDEiYiv0IsYqCjiscPekoCHKl6C4EGkSiYhvdWPU0fUn24AWHRNWAugxJoCsTPwR4WBoplG3ZjsCpchiy(225jiKHbzXXjsCpcVumzp482opnaX8DMN68sqKesjuC4cjx05W9OIOrKpEscuQlDHBdnCn4W1tynkJRrhoP2uRvC4SaEphMszqfdVumzp480CEAmp157npezKkArjziUeejHucfhUqYfDoCICe1ezb8EholG3hpbtD4WukdQyCPlCBajxdoC9ewJY4A0HtQn1AfhEZ57npezKkArjziUeejHucL5BBNV58SaEphMszqfdhMcHY80CEAmFB78SaEphMszqfdVumzp482sF((y(oZtD(MZ7xWHYyPyYEW5TFERNVZ8G88Wa1yIPuG1eoVTZtqWC((CEB4068DMN68Wa1yIPuG1eoVT0NhuPwH1OCOpMsbwtOdxi5IohomLYlgJlDHBdT6AWHRNWAugxJoCsTPwR4WBoFZ5tXOxYHPuguXW1tynkZ8uNV58SaEphMszqfdhMcHY80CEAmFB78SaEphMszqfdVumzp482sFEADEQZZc49CPiYTKyaGbkfhMcHY80C((y(oZ32oFV5tXOxYHPuguXW1tynkZ8uNV58SaEpxkICljgayGsXHPqOmpnNVpMVTDEwaVNtK4EeoqW8DMVZ8uNNfW75qKrQOIfGSqlm9somfcL5P580yEQZZc49CdWjvuXcqwOfMEjhMcHY80CEAmp15zb8EEPekgfcJEur0ibbCPwCykekZtZ5T2ooFB78SaEpVucfJcHrpQikhiy(oZtDEyGAmXukWAc5WukVymZtZ5bvQvynkh6JPuG1eop15BoFV5bvQvynkx6pcHZ32oFV5zb8EorI7r4abZ32oFV5dkfuomLccuG157mFB78(fCOmwkMShCEAsFETVucqQXCX05b55fywIjgGSqR57Z5bjqmFB789MhImsfTOKmexcIKqkHIdxi5IohomLccuGvx6c3g7Y1GdxpH1OmUgD4KAtTwXHZc49CIe3JWbcMN68SaEpNiX9i8sXK9GZtZ5bty4ysFnp15L(1AtLdZsfk7boctPG8sokZtDEguYXqOZVLYlft2doVTZxkMSh0HlKCrNdhcC(Tux6c3g7axdoC9ewJY4A0HtQn1AfholG3ZjsCpchiyEQZZc49CIe3JWlft2dopnNhmHHJj918uNx6xRnvomlvOSh4imLcYl5O4WfsUOZHJHqNFl1LUWTPpCn4W1tynkJRrhUqYfDoCiW53sD4KAtTwXHxQVuyiH1OZtDEjiscPekZtDEVbHQ5BoFkfyn55IPXefzwD((C(MZBZ8G88Wa1yIHeyQZ3z(oZdYZdduJjMsbwt482sFEIUM5BoV3Gq18nN3M57Z5HbQXetPaRjC(oZdYZBnNwNVZ82pVnZdYZdduJjMsbwt48uNV58Wa1yIPuG1eoVTZB982pFkg9sEAXErme6GC9ewJYmFB78mOKJHqNFlLNlHYEGNVZ8uNV589Mx6xRnvomlvOSh4imLcYl5OmFB789MNfW75ejUhHdemFB789MpOuq5qGZVLoFN5PoFZ5zb8EorI7r4LIj7bN325lft2doFB789MNfW75ejUhHdemFhhojmIrJPuG1e6c3Ax6c3g7ORbhUEcRrzCn6WfsUOZHJHqNFl1HtQn1AfhEP(sHHewJop15LGijKsOmp159geQMV58PuG1KNlMgtuKz157Z5BoVnZdYZdduJjgsGPoFN57mpippmqnMykfynHZBl95TR5PoFZ57nV0VwBQCywQqzpWrykfKxYrz(2257nplG3ZjsCpchiy(2257nFqPGYXqOZVLoFN5PoFZ5zb8EorI7r4LIj7bN325lft2doFB789MNfW75ejUhHdemFhhojmIrJPuG1e6c3Ax6cNgGW1GdxpH1OmUgD4cjx05WHPAmsf9gPuhoP2uRvC4L6lfgsyn68uNxcIKqkHY8uN3BqOA(MZNsbwtEUyAmrrMvNVpNV582mpippmqnMyibM68DMVZ82sFEADEQZ3C(EZl9R1MkhMLku2dCeMsb5LCuMVTD(EZZc49CIe3JWbcMVTD(EZhukOCyQgJurVrkD(ooCsyeJgtPaRj0fU1U0fonS21GdxpH1OmUgD4KAtTwXHlbrsiLqXHlKCrNd)ulIyi05sx40WgxdoC9ewJY4A0HtQn1AfhUeejHucfhUqYfDo8qIXhXqOZLUWPbnCn4W1tynkJRrhoP2uRvC4sqKesjuC4cjx05W9agtedHox6cNgGKRbhUEcRrzCn6Wj1MATIdNfW75qKrQOIfGSqlm9somfcL5P580yEQZ3CEjiscPekZ32oplG3ZnaNurflazHwy6LCykekZtFEAmFN5PoFZ5BoplG3ZTqQArve5JQb4uoqW8TTZZc49CdWjvuXcqwOfMEjhiy(225HbQXetPaRjCEBPpVnZtD(EZZc49CiYivuXcqwOfMEjhiy(oZtD(MZ3BEPFT2u5WSuHYEGJWukiVKJY8TTZ3BEwaVNtK4EeoqW8DMVTDEPFT2u5WSuHYEGJWukiVKJY8uNNfW75ejUhHdemp15dkfuoezKkArjzO574WfsUOZHBaoPIWSwkQlDHtdA11GdxpH1OmUgD4KAtTwXHl9R1MkhMLku2dCeMsb5LCuMNMZtJ5BBNV38SaEpNiX9iCGG5BBNV38bLckhImsfTOKmKdxi5IohoezKkArjzix6cNg2LRbhUqYfDoCiW53sD46jSgLX1OlDPdpOuccJvsxdUWT21GdxpH1OmUgD4OahouthUqYfDoCqLAfwJ6WbvmaQdhKC4Gkv8em1Hd9XukWAcDPlCBCn4W1tynkJRrhokWHlmmoCHKl6C4Gk1kSg1HdQyauhU1oCsTPwR4WL(1AtLlfrULedamqP46jSgLXHdQuXtWuho0htPaRj0LUWPHRbhUEcRrzCn6WrboCHHXHlKCrNdhuPwH1OoCqfdG6WT2HtQn1AfhEkg9somLYGkgUEcRrzC4Gkv8em1Hd9XukWAcDPlCqY1GdxpH1OmUgD4OahUWW4WfsUOZHdQuRWAuhoOIbqD4w7Wj1MATIdx6xRnvomlvOSh4imLcYl5OmVTZBZ8uNx6xRnvUue5wsmaWaLIRNWAughoOsfpbtD4qFmLcSMqx6cNwDn4W1tynkJRrhokWHdbyD4cjx05WbvQvynQdhuXaOoCRD4KAtTwXH3B(um6L80I9Iyi0b56jSgLXHdQuXtWuho0htPaRj0LUWTlxdoCHKl6C4yi0rzVOhvyoC9ewJY4A0LUWTdCn4W1tynkJRrh(jyQdx6hgskbg9OlJiFmazHwoCHKl6C4s)WqsjWOhDze5Jbil0YLUW7dxdoC9ewJY4A0HlKCrNdpaLl6C4mHDc2sIbLgGshU1U0fUD01Gdxi5IohoezKkArjzihUEcRrzCn6sx4wdcxdoCHKl6C4WukiqbwD46jSgLX1OlDPlD4GQfCrNlCBaH12rqyhTbeoClK62dm0HtlJfGQuzM3M5fsUOBEZctiF66WHbkXfU1GWghEqH8RrD40E(gfJCeDE7WcyzMU0E(qzgaPfS0sWBgcGLtqywcxmaJKl6iL4tlHlgXYPlTNVlWPZBniz182acBaX0D6s75TtHKdScPfMU0E((EE7mdJYmpoYi18nQcgF6s75775TtHKdSYmFkfynJRFEIav48jAEsyeJgtPaRjKpDP989984lwGz9HnVDUFT2uNplzZ5niefGa48nzqNDpNhaQZdCNsuiuQWMhuPwH1OZdd7sPV6WNU0E((EEAXkgcuLzEArlOQjS5Xd2AZ5jOJzZfDZ7r182j1OWCfZ82zZc(W0lPLoFyia7UXmFibuD(nNhvZhgcyElqNDpNhUhrNNw(oTavsD(foFOfCiTMpOwuTzy8P70L2ZtlPVucqQmZZQEuPZtqySsopRcEpiFE7mHObjC(dD9DiPW8aM5fsUOdop6mHXNU0EEHKl6G8GsjimwjP7ncKY0L2ZlKCrhKhukbHXkP90T0JqmtxApVqYfDqEqPeegRK2t3sbamMEPKl6MUtxApVDUFT2uNhuPwH1OWPlTNxi5IoipOuccJvs7PBjOsTcRrT6emLU0FecTcuXaO0L(1AtLdZsfk7boctPG8soktxApVqYfDqEqPeegRK2t3sqLAfwJA1jykDP)OeyfOIbqPl9R1MkxkICljgayGsXl5OmDNU0EE8ukVymZd684PuqGcSoFkfynNNaKiVF6kKCrhKhukbHXkjDqLAfwJA1jykDOpMsbwtOvGkgaLoinDfsUOdYdkLGWyL0E6wcQuRWAuRobtPd9XukWAcTcfqxyyScuXaO0T2Q1tx6xRnvUue5wsmaWaLIRNWAuMPRqYfDqEqPeegRK2t3sqLAfwJA1jykDOpMsbwtOvOa6cdJvGkgaLU1wTE6Py0l5WukdQy46jSgLz6kKCrhKhukbHXkP90TeuPwH1OwDcMsh6JPuG1eAfkGUWWyfOIbqPBTvRNU0VwBQCywQqzpWrykfKxYrXwBOk9R1MkxkICljgayGsX1tynkZ0vi5IoipOuccJvs7PBjOsTcRrT6emLo0htPaRj0kuaDiaRvGkgaLU1wTE69sXOxYtl2lIHqhKRNWAuMPRqYfDqEqPeegRK2t3sme6OSx0JkSP70L2ZJFsamekNVKLzEwaVxzMhMscNNv9OsNNGWyLCEwf8EW5LJz(Gs77auM7bE(fopd6u(0L2ZlKCrhKhukbHXkP90TeEsamekJWus40vi5IoipOuccJvs7PBjauJBQywDcMsx6hgskbg9OlJiFmazHwtxHKl6G8GsjimwjTNULbOCrNvmHDc2sIbLgGs6wpDfsUOdYdkLGWyL0E6wcrgPIwusgA6kKCrhKhukbHXkP90TeMsbbkW60D6s75PL0xkbivM5vq1kS5ZftNpdPZlKevZVW5fqL1iSgLpDfsUOdshImsfzvbB6s75Tt2HWPRqYfDq7PBjRwqTOShyRwpDwaVNtK4EeoqW0vi5IoO90TeaQXnvmRobtPl9ddjLaJE0LrKpgGSqlRwp9ESaEpNiX9iCGaQmOKJHqNFlLNlHYEGPYGsoe48BP8Cju2dm1M9sXOxYHPAmsf9gPuUEcRrzABzqjhMQXiv0BKs55sOSh4otxHKl6G2t3sWasXSYfr(O0VwOmKvRNEZEPy0l5WukdQy46jSgLPTLfW75WukdQy4abDO2JfW75ejUhHdeqLbLCme68BP8Cju2dmvguYHaNFlLNlHYEGP2Sxkg9somvJrQO3iLY1tynktBldk5WungPIEJukpxcL9a3z6kKCrh0E6wca14MkMvQ3RKmEcMsNegXGYcDljYAeyA16P3JfW75ejUhHdeqLbLCme68BP8Cju2dmvguYHaNFlLNlHYEGP2Sxkg9somvJrQO3iLY1tynktBldk5WungPIEJukpxcL9a3z6kKCrh0E6wca14MkMvNGP0HHwq1kcQEiSyPMLy16P3JfW75ejUhHdeqThlG3ZznieJbaMCGaRsPaRzC90zqjhgAbvRiO6HW4WuiuSLoToDfsUOdApDlbGACtfZQtWu6yYTEfMOiYhXeMtHqRwpDwaVNtK4EeEPyYEqBTgeTTSaEpNiX9i8sXK9G2csuzb8EUue5wsmaWaLIdtHqXw7QT1VGdLXsXK9G00gRNUcjx0bTNULSgeIjI8XmKg1tXcZQ1tNGqggKfhNiX9i8sXK9G2sdqmDfsUOdApDlXumufwe5JgaYYezkvWGwTE69yb8EorI7r4abuBkWSetmazHw00gATTLGqggKfhNiX9i8sXK9G2sdq0Hkdk5qGZVLYlft2dAR1GGkdk5yi053s5LIj7bT1AqqTzVum6LCyQgJurVrkLRNWAuM2wguYHPAmsf9gPuEPyYEqBTgeDMUcjx0bTNULba16dBpWrwJaZPRqYfDq7PBzTbbgnUxegieD6kKCrh0E6wsqhrVSKuzIEJGPtxHKl6G2t3YmKgboweWXe9OIOwTE6SaEpVucfJcHrpQikhiGkdk5yi053s55sOShyQmOKdbo)wkpxcL9atTzVum6LCyQgJurVrkLRNWAuM2wguYHPAmsf9gPuEUek7bUZ0vi5IoO90T0cuzyav3lwkeDYr0PRqYfDq7PBPhraGktu6xRn1iRkywTE6n7bQuRWAuU0FecBB7Xc49CIe3JWbc6qLbLCme68BP8Cju2dmvguYHaNFlLNlHYEGP2Sxkg9somvJrQO3iLY1tynktBldk5WungPIEJukpxcL9a3z6kKCrh0E6wMHq1bNUcjx0bTNULaqnUPIbTA90zb8EorI7r4abTT(fCOmwkMShKM2aIPRqYfDq7PBPfsvlQIiFunaNoDP98cjx0bTNUL7DAbQKQvRNU0VwBQCZcQAclcd2AtUEcRrzO2KGqggKfhFpIuNKl64LIj7bPPnTTeeYWGS44e1OWCftuml4dtVKxkMShKMwBtNPRqYfDq7PB5EePojx0z16P3JfW75ejUhHdeqTjlG3ZXumufwe5JgaYYezkvWGCGG22MnjiKHbzXXXumufwe5JgaYYezkvWG8sXK9G2AdiAB7PqOEeLJPyOkSiYhnaKLjYuQGb5yIDdQ6qvcIKqkHsNouBYc49CmfdvHfr(ObGSmrMsfmihiOTvcIKqkHshQmOKdbo)wkVumzpOT9bvguYXqOZVLYlft2dAR12qTjdk5WungPIEJukVumzpOT2vBBVum6LCyQgJurVrkLRNWAuMotxHKl6G2t3sIAuyUIjkMf8HPxA16P3JfW75ejUhHdeqTjlG3ZXumufwe5JgaYYezkvWGCGG22MnjiKHbzXXXumufwe5JgaYYezkvWG8sXK9G2AdiAB7PqOEeLJPyOkSiYhnaKLjYuQGb5yIDdQ6qvcIKqkHsNouBYGsoe48BP8sXK9G2AdvguYXqOZVLYZLqzpWuBYGsomvJrQO3iLYZLqzpWTT9sXOxYHPAmsf9gPuUEcRrz60z6kKCrh0E6w6bQWIiFunaNA16P3KfW75ejUhHde02sqiddYIJtK4EeEPyYEqBPbi6qfImsfTOKmexcIKqkHY0vi5IoO90T0JkIgr(4jjqPwTE6nzb8EorI7r4abTTeeYWGS44ejUhHxkMSh0wAaIouLGijKsOmDNU0EE8a9y0coDfsUOdApDljYrutKfW7T6emLomLYGkgRwpDwaVNdtPmOIHxkMShKM0GApiYiv0IsYqCjiscPektxHKl6G2t3sykLxmgRwp9M9GiJurlkjdXLGijKsO022KfW75WukdQy4WuiuOjnABzb8EomLYGkgEPyYEqBP3hDO20VGdLXsXK9G2BDhqggOgtmLcSMqBjiy2N2WP1ouHbQXetPaRj0w6Gk1kSgLd9XukWAcNUcjx0bTNULWukiqbwTA90B2mfJEjhMszqfdxpH1OmuBYc49CykLbvmCykek0KgTTSaEphMszqfdVumzpOT0PvQSaEpxkICljgayGsXHPqOqZ(OtBBVum6LCykLbvmC9ewJYqTjlG3ZLIi3sIbagOuCykek0SpABzb8EorI7r4abD6qLfW75qKrQOIfGSqlm9somfcfAsdQSaEp3aCsfvSaKfAHPxYHPqOqtAqLfW75LsOyuim6rfrJeeWLAXHPqOqtRTJTTSaEpVucfJcHrpQikhiOdvyGAmXukWAc5WukVym0euPwH1OCOpMsbwti1M9avQvynkx6pcHTT9yb8EorI7r4abTT9ckfuomLccuG1oTT(fCOmwkMShKM01(sjaPgZftbzbMLyIbil0Qpbjq022dImsfTOKmexcIKqkHY0vi5IoO90TecC(TuRwpDwaVNtK4EeoqavwaVNtK4EeEPyYEqAcMWWXK(IQ0VwBQCywQqzpWrykfKxYrHkdk5yi053s5LIj7bTTumzp40vi5IoO90TedHo)wQvRNolG3ZjsCpchiGklG3ZjsCpcVumzpinbty4ysFrv6xRnvomlvOSh4imLcYl5OmDNU0EE7qudWPRqYfDq7PBje48BPwrcJy0ykfynH0T2Q1tVuFPWqcRrPkbrsiLqHQ3GqvZukWAYZftJjkYSAF20gqggOgtmKatTthqggOgtmLcSMqBPt0100BqOQPn9jmqnMykfynHDazR50Ah7TbKHbQXetPaRjKAtyGAmXukWAcT1A7tXOxYtl2lIHqhKRNWAuM2wguYXqOZVLYZLqzpWDO2SN0VwBQCywQqzpWrykfKxYrPTThlG3ZjsCpchiOTTxqPGYHaNFlTd1MSaEpNiX9i8sXK9G2wkMShSTThlG3ZjsCpchiOZ0vi5IoO90TedHo)wQvKWignMsbwtiDRTA90l1xkmKWAuQsqKesjuO6niu1mLcSM8CX0yIImR2NnTbKHbQXedjWu70bKHbQXetPaRj0w62f1M9K(1AtLdZsfk7boctPG8sokTT9yb8EorI7r4abTT9ckfuogcD(T0ouBYc49CIe3JWlft2dABPyYEW22ESaEpNiX9iCGGotxHKl6G2t3syQgJurVrk1ksyeJgtPaRjKU1wTE6L6lfgsynkvjiscPeku9geQAMsbwtEUyAmrrMv7ZM2aYWa1yIHeyQD6ylDALAZEs)ATPYHzPcL9ahHPuqEjhL22ESaEpNiX9iCGG22EbLckhMQXiv0BKs7mDNU0EE7w6PLKOcoDfsUOdApDlp1IigcDwTE6sqKesjuMUcjx0bTNULHeJpIHqNvRNUeejHucLPRqYfDq7PBPhWyIyi0z16PlbrsiLqz6kKCrh0E6wAaoPIWSwkQvRNolG3ZHiJurflazHwy6LCykek0KguBkbrsiLqPTLfW75gGtQOIfGSqlm9somfcf60Od1Mnzb8EUfsvlQIiFunaNYbcABzb8EUb4KkQybil0ctVKde02cduJjMsbwtOT0THApwaVNdrgPIkwaYcTW0l5abDO2SN0VwBQCywQqzpWrykfKxYrPTThlG3ZjsCpchiOtBR0VwBQCywQqzpWrykfKxYrHklG3ZjsCpchiGAqPGYHiJurlkjd1z6kKCrh0E6wcrgPIwusgYQ1tx6xRnvomlvOSh4imLcYl5OqtA022JfW75ejUhHde022lOuq5qKrQOfLKHMUtxApVDBXyYqfW8EunpgcuftVC6kKCrh0E6wcbo)wQlDPZb]] )


end