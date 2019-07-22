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
        swipe = {
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

            copy = { 106785, 213771 }
        },


        thrash = {
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


    spec:RegisterPack( "Balance", 20190721.2330, [[dC0E3aqiPspcvHljLs2eQ4tsPqJsk6usjRca1ROkAwOQ6wsPODHYVqvAyqehdvLLrv4zaW0OkPUgaY2GivFJQezCuLKZbrI1rvI6DqKKMhQIUhQ0(OQ4GuLqlKQQEivjyIsPaxeIKQnkLcYhLsb1jHifRuQyMqKe7KQslfIKYtryQuvzVu5VcnyvDyslMsEmstgrxMyZc(mGgTu40kTAisPxdHztXTH0Uv53GgoLA5sEoutx01bA7a03HOgVuk15Pk16Ls18LQ2VID858ZrqQP481dKWhsbjEjp4J5baaasaaa5isVTfhHTsrOafhXPOIJWF1OhvCe2Q3gOs68ZrGHGfvCenY0g7L5LxGB2a0IrHO8IxuqJMl8OLgsEXlkLxhHf4AsKMZz5ii1uC(6bs4dPGeVKh8X8aaaajE4iuWSbSCeelQxWr0yjjLZz5iifm1rWJ59xn6rL5BdkWLC6WJ5BKPn2lZlVa3SbOfJcr5fVOGgnx4rlnK8IxukVthEmFhqJ3Z7bF8pVhiHpKY8T58EGeVSxZ30z6WJ59cn0dOG9YthEmFBoVxKKuiNNaA0AE)ffLnD4X8T58EHg6buiNp1cOKXnmpvXcE(eop1BQrIPwaLeZMo8y(2CEIf12SbVN3l2UuBkZNLU58giebOnE(MKWRnMZdIL5bVtOcgRL3ZdOwRAzK5XEFP22TythEmFBopsnbfcOqopsLfqX498e2BT58u4rU5cV5dWAEVGyeCUQzEVOzbEOYLivN3BiyB0yMVHcOm)MZdR59gcopYWRnMZJ3JkZJ0CNuaQPm)INVXcSHuZBxlS20BMJWS4e78Zrqkbf0Ko)C(YNZphHsZfEocm0Ov0suuhHCQLriD(7sNVE48ZriNAzesN)ocATPuR6iSadbgvJ7rzG2ocLMl8CewsHLcXEaDPZxa48ZriNAzesN)ocLMl8CeA74gAP4yaEzegI2qKLYrqRnLAvhr35TadbgvJ7rzG2ZZzEsyYqHWlSLWYLIypGZZzEsyYWGxylHLlfXEaNNZ8nNV78PAKlz4umgTIbJwcto1YiKZ33ppjmz4umgTIbJwclxkI9aoFlhXPOIJqBh3qlfhdWlJWq0gISuU05Rx78ZriNAzesN)ocATPuR6iAoF35t1ixYWPwgyrYKtTmc5899ZBbgcmCQLbwKmq75BnpN57oVfyiWOACpkd0EEoZtctgkeEHTewUue7bCEoZtctgg8cBjSCPi2d48CMV58DNpvJCjdNIXOvmy0syYPwgHC(((5jHjdNIXOvmy0sy5srShW5B5iuAUWZraeulYvVime12LcMnCPZxaY5NJqo1YiKo)Deknx45iSHuesI32fYifIAdMAUWlskaUuXrqRnLAvhr35TadbgvJ7rzG2ZZzEsyYqHWlSLWYLIypGZZzEsyYWGxylHLlfXEaNNZ8nNV78PAKlz4umgTIbJwcto1YiKZ33ppjmz4umgTIbJwclxkI9aoFlhHeccnJNIkocQ3udml4T0OLrXPlD(I0D(5iKtTmcPZFhHsZfEocCJfqPIakhenwIzPocATPuR6i6oVfyiWOACpkd0EEoZtctgUXcOuraLdIYWPsrmVpCNhGCeNIkocCJfqPIakhenwIzPU05RxY5NJqo1YiKo)De0AtPw1rqHqdje5Jr14EuwjO6E459zEaGehHsZfEocldesgHHy2qIYjOE7sNVELZphHCQLriD(7iO1MsTQJO78wGHaJQX9Omq755mFZ5vCwQjAdrwQ5558EaqZ33ppfcnKqKpgvJ7rzLGQ7HN3N5basMV18CMNeMmm4f2syLGQ7HN3N55djZZzEsyYqHWlSLWkbv3dpVpZZhsMNZ8nNV78PAKlz4umgTIbJwcto1YiKZ33ppjmz4umgTIbJwcReuDp88(mpFiz(wocLMl8CeOckS8ocdrdiDjJKLOOyx68fP48ZrO0CHNJWgS2G37bmAzuC6iKtTmcPZFx68LpK48ZrO0CHNJOwBBJe3lITvQ4iKtTmcPZFx68Lp(C(5iuAUWZrqHhvUS0uiJbJIkoc5ulJq683LoF5ZdNFoc5ulJq683rqRnLAvhHfyiWkHIWiyCmalQWaTNNZ8KWKHcHxylHLlfXEaNNZ8KWKHbVWwclxkI9aopN5BoF35t1ixYWPymAfdgTeMCQLriNVVFEsyYWPymAfdgTewUue7bC(wocLMl8CezdjcEwqWJmgGfvCPZx(aGZphHsZfEocKHLHeqzVyjy4PhvCeYPwgH05VlD(YNx78ZriNAzesN)ocATPuR6iAoF35buRvTmctBpIXZ33pF35TadbgvJ7rzG2Z3AEoZtctgkeEHTewUue7bCEoZtctgg8cBjSCPi2d48CMV58DNpvJCjdNIXOvmy0syYPwgHC(((5jHjdNIXOvmy0sy5srShW5B5iuAUWZreGuqSqg12LAtjAjkQlD(Yha58ZrO0CHNJiBaRd7iKtTmcPZFx68LpKUZphHsZfEocqSe3uqXoc5ulJq683LoF5Zl58ZrO0CHNJazTQfwryikgWtCeYPwgH05VlD(YNx58ZriNAzesN)ocATPuR6i6oVfyiWOACpkd0EEoZ3CElWqGHkOWY7imenG0LmswIIIzG2Z33pFZ5BopfcnKqKpgQGclVJWq0asxYizjkkMvcQUhEEFM3dKmFF)8DNxWy5OcdvqHL3ryiAaPlzKSeffZqvKwynFR55mVAhPnekI5BnFR55mFZ5TadbgQGclVJWq0asxYizjkkMbApFF)8QDK2qOiMV18CMNeMmm4f2syLGQ7HN3N59Q55mpjmzOq4f2syLGQ7HN3N55ZJ55mFZ5jHjdNIXOvmy0syLGQ7HN3N5r6Z33pF35t1ixYWPymAfdgTeMCQLriNVLJqP5cphXEuTonx45sNV8HuC(5iKtTmcPZFhbT2uQvDeDN3cmeyunUhLbAppN5BoVfyiWqfuy5DegIgq6sgjlrrXmq7577NV58nNNcHgsiYhdvqHL3ryiAaPlzKSeffZkbv3dpVpZ7bsMVVF(UZlySCuHHkOWY7imenG0LmswIIIzOkslSMV18CMxTJ0gcfX8TMV18CMV58KWKHbVWwcReuDp88(mVhZZzEsyYqHWlSLWYLIypGZZz(MZtctgofJrRyWOLWYLIypGZ33pF35t1ixYWPymAfdgTeMCQLriNV18TCeknx45iOIrW5QMOAwGhQCPlD(6bsC(5iKtTmcPZFhbT2uQvDenN3cmeyunUhLbApFF)8ui0qcr(yunUhLvcQUhEEFMhaiz(wZZzEm0Ove5sZgm1osBiueocLMl8CebWY7imefd4jU05Rh858ZriNAzesN)ocATPuR6iAoVfyiWOACpkd0E(((5PqOHeI8XOACpkReuDp88(mpaqY8TMNZ8QDK2qOiCeknx45icWIkryiEAcwIlD(6Hho)CeYPwgH05VJGwBk1QoclWqGHtTmWIKvcQUhEEEopaMNZ8DNhdnAfrU0SbtTJ0gcfHJqP5cphbvpQyIwGHGJWcmeINIkocCQLbwKU05RhaW5NJqo1YiKo)De0AtPw1r0CElWqGHtTmWIKHtLIyEEopaMVVFElWqGHtTmWIKvcQUhEEF4oVxnFR55mp2wmMyQfqjXZ7d35buRvTmcdhIPwaLeppN5BoFQfqjz5IkXegjxzEpNNV5Bnpapp2wmMyQfqjXZ7Z8uioNVTM3dga5iuAUWZrGtTcQX4sNVE41o)CeYPwgH05VJGwBk1QoIMZNQrUKHtTmWIKjNAzeY55mFZ5Tadbgo1YalsgovkI5558ay(((5Tadbgo1YalswjO6E459H78a08CM3cmeyAr1BPrBqdwlgovkI5558E18TMVVF(UZNQrUKHtTmWIKjNAzeY55mFZ5TadbMwu9wA0g0G1IHtLIyEEoVxnFF)8wGHaJQX9Omq75BnFR55mp2wmMyQfqjXmCQvqnM5558aQ1QwgHHdXulGsINNZ8wGHaZaEAffuBiYsHkxYWPsrmVNZBbgcmm0OvuqTHilfQCjdNkfX88CEVEEoZBbgcmm0OvuqTHilfQCjdNkfX88CEampN5TadbMb80kkO2qKLcvUKHtLIyEEopaMNZ8nNV78A7sTPWWzjkI9agXPwywPhI577NV78wGHaJQX9Omq7577NV782LaidNAHblGY8TMVVF(ulGsYYfvIjmsUY88K78sBluWuI5IkZdWZR4Sut0gISuZ3wZ71iz(((57opgA0kICPzdMAhPnekchHsZfEocCQfgSakU05RhaKZphHCQLriD(7iO1MsTQJWcmeyunUhLbAppN5TadbgvJ7rzLGQ7HNNNZdKsYq12EEoZRTl1McdNLOi2dyeNAHzLEiMNZ8KWKHcHxylHvcQUhEEFMVeuDpSJqP5cphbg8cBjU05RhiDNFoc5ulJq683rqRnLAvhHfyiWOACpkd0EEoZBbgcmQg3JYkbv3dpppNhiLKHQT98CMxBxQnfgolrrShWio1cZk9q4iuAUWZrGcHxylXLoF9Wl58ZriNAzesN)ocLMl8CeyWlSL4iO1MsTQJOKqj4gQLrMNZ8QDK2qOiMNZ8bdewZ3C(ulGsYYfvIjmsUY8T18nN3J5b45X2IXeBO4uMV18TMhGNhBlgtm1cOK459H78uznZ3C(GbcR5BoVhZ3wZJTfJjMAbus88TMhGNNpganFR59CEpMhGNhBlgtm1cOK455mFZ5X2IXetTakjEEFMNV59C(unYLSe59IOq4HzYPwgHC(((5jHjdfcVWwclxkI9aoFR55mFZ57oV2UuBkmCwIIypGrCQfMv6Hy(((57oVfyiWOACpkd0E(((57oVDjaYWGxylz(wZZz(MZBbgcmQg3JYkbv3dpVpZxcQUhE(((57oVfyiWOACpkd0E(wocQ3uJetTakj25lFU05RhELZphHCQLriD(7iuAUWZrGcHxylXrqRnLAvhrjHsWnulJmpN5v7iTHqrmpN5dgiSMV58PwaLKLlQetyKCL5BR5BoVhZdWZJTfJj2qXPmFR5Bnpapp2wmMyQfqjXZ7d35r6ZZz(MZ3DETDP2uy4SefXEaJ4ulmR0dX899Z3DElWqGr14EugO9899Z3DE7saKHcHxylz(wZZz(MZBbgcmQg3JYkbv3dpVpZxcQUhE(((57oVfyiWOACpkd0E(wocQ3uJetTakj25lFU05RhifNFoc5ulJq683rO0CHNJaNIXOvmy0sCe0AtPw1rusOeCd1YiZZzE1osBiueZZz(GbcR5BoFQfqjz5IkXegjxz(2A(MZ7X8a88yBXyInuCkZ3A(wZ7d35bO55mFZ57oV2UuBkmCwIIypGrCQfMv6Hy(((57oVfyiWOACpkd0E(((57oVDjaYWPymAfdgTK5B5iOEtnsm1cOKyNV85sNVaajo)CeYPwgH05VJGwBk1Qoc1osBiueocLMl8CeNGCefcpx68fa858ZriNAzesN)ocATPuR6iu7iTHqr4iuAUWZr0qnHikeEU05la8W5NJqo1YiKo)De0AtPw1rO2rAdHIWrO0CHNJiaAmrui8CPZxaaaNFoc5ulJq683rqRnLAvhHfyiWWqJwrb1gISuOYLmCQueZZZ5bW8CMV58QDK2qOiMVVFElWqGzapTIcQnezPqLlz4uPiMN78ay(wZZz(MZ3CElWqGHSw1cRimefd4jmq7577N3cmeygWtROGAdrwku5sgO9899ZJTfJjMAbus88(WDEpMNZ8DN3cmeyyOrROGAdrwku5sgO98TMNZ8nNV78A7sTPWWzjkI9agXPwywPhI577NV78wGHaJQX9Omq75BnFF)8A7sTPWWzjkI9agXPwywPhI55mVfyiWOACpkd0EEoZBxcGmm0Ove5sZgZ3YrO0CHNJWaEAfXzTiex68faETZphHCQLriD(7iO1MsTQJqBxQnfgolrrShWio1cZk9qmppNhaZ33pF35TadbgvJ7rzG2Z33pF35TlbqggA0kICPzdhHsZfEocm0Ove5sZgU05laaiNFocLMl8CeyWlSL4iKtTmcPZFx6shHDjuiQLMo)C(YNZphHCQLriD(7iG2ocSKocLMl8CeaQ1QwgXraOAafhHx7iauR4POIJahIPwaLe7sNVE48ZriNAzesN)ocOTJqjjDeknx45iauRvTmIJaq1akoc(Ce0AtPw1rOTl1MctlQElnAdAWAXKtTmcPJaqTINIkocCiMAbusSlD(caNFoc5ulJq683raTDekjPJqP5cphbGATQLrCeaQgqXrWNJGwBk1QoIunYLmCQLbwKm5ulJq6iauR4POIJahIPwaLe7sNVETZphHCQLriD(7iG2ocLK0rO0CHNJaqTw1YiocavdO4i4ZrqRnLAvhH2UuBkmCwIIypGrCQfMv6HyEFM3J55mV2UuBkmTO6T0OnObRfto1YiKoca1kEkQ4iWHyQfqjXU05la58ZriNAzesN)ocOTJadA5iuAUWZraOwRAzehbGQbuCe85iO1MsTQJO78PAKlzjY7frHWdZKtTmcPJaqTINIkocCiMAbusSlD(I0D(5iuAUWZrGcHhI9IbyH6iKtTmcPZFx681l58ZriNAzesN)oItrfhH2oUHwkogGxgHHOnezPCeknx45i02Xn0sXXa8YimeTHilLlD(6vo)CeYPwgH05VJqP5cphHnmx45ii9(u0LgTlXgMoc(CPZxKIZphHsZfEocm0Ove5sZgoc5ulJq683LoF5djo)Ceknx45iWPwyWcO4iKtTmcPZFx6sx6iauk8cpNVEGe(qkiXlXhaXqIxXha5iqwRBpGyhbsdQnSsHCEpMxP5cV5nloXSPJJaBluNV8HepCe2fmSgXrWJ59xn6rL5BdkWLC6WJ5BKPn2lZlVa3SbOfJcr5fVOGgnx4rlnK8IxukVthEmFhqJ3Z7bF8pVhiHpKY8T58EGeVSxZ30z6WJ59cn0dOG9YthEmFBoVxKKuiNNaA0AE)ffLnD4X8T58EHg6buiNp1cOKXnmpvXcE(eop1BQrIPwaLeZMo8y(2CEIf12SbVN3l2UuBkZNLU58giebOnE(MKWRnMZdIL5bVtOcgRL3ZdOwRAzK5XEFP22TythEmFBopsnbfcOqopsLfqX498e2BT58u4rU5cV5dWAEVGyeCUQzEVOzbEOYLivN3BiyB0yMVHcOm)MZdR59gcopYWRnMZJ3JkZJ0CNuaQPm)INVXcSHuZBxlS20B20z6WJ5rQ32cfmfY5TKaSK5PqulnN3saUhMnVxKsf7ep)bV2SHwObqZ8knx4HNhEgVzthEmVsZfEyMDjuiQLMCdgfJy6WJ5vAUWdZSlHcrT00tU8gGqYPdpMxP5cpmZUeke1stp5YRccevUuZfEtNPdpM3l2UuBkZdOwRAze80HhZR0CHhMzxcfIAPPNC5fqTw1Yi8FkQWvBpIX8dOAafUA7sTPWWzjkI9agXPwywPhIPdpMxP5cpmZUeke1stp5YlGATQLr4)uuHR2EuT5hq1akC12LAtHPfvVLgTbnyTyLEiMothEmprQvqnM5bCEIulmybuMp1cOKZtbtyimDuAUWdZSlHcrT0KlGATQLr4)uuHloetTakjMFavdOW1RNoknx4Hz2LqHOwA6jxEbuRvTmc)NIkCXHyQfqjX8dT5QKK8dOAafU8X)g4QTl1MctlQElnAdAWAXKtTmc50rP5cpmZUeke1stp5YlGATQLr4)uuHloetTakjMFOnxLKKFavdOWLp(3a3unYLmCQLbwKm5ulJqoDuAUWdZSlHcrT00tU8cOwRAze(pfv4IdXulGsI5hAZvjj5hq1akC5J)nWvBxQnfgolrrShWio1cZk9q4JhC02LAtHPfvVLgTbnyTyYPwgHC6O0CHhMzxcfIAPPNC5fqTw1Yi8FkQWfhIPwaLeZp0Mlg0IFavdOWLp(3a3UPAKlzjY7frHWdZKtTmc50rP5cpmZUeke1stp5YlkeEi2lgGf60z6WJ5jo1g3aMZx6soVfyiiKZJtnXZBjbyjZtHOwAoVLaCp886roVDjTPnmZ9ao)INNeEcB6WJ5vAUWdZSlHcrT00tU8Ip1g3aMrCQjE6O0CHhMzxcfIAPPNC5felXnfu(pfv4QTJBOLIJb4LryiAdrwQPJsZfEyMDjuiQLMEYLxByUWJFsVpfDPr7sSHjx(Moknx4Hz2LqHOwA6jxEXqJwrKlnBmDuAUWdZSlHcrT00tU8ItTWGfqz6mD4X8i1BBHcMc58cGs5985IkZNnK5vAcR5x88kG6AulJWMoknx4H5IHgTIwIIoD4X8EH2a80rP5cpSNC51skSui2di)BGRfyiWOACpkd0E6O0CHh2tU8cIL4Mck)NIkC12Xn0sXXa8YimeTHilf)BGBxlWqGr14EugOnhsyYqHWlSLWYLIypGCiHjddEHTewUue7bKtZUPAKlz4umgTIbJwcto1YiK99KWKHtXy0kgmAjSCPi2dyRPJsZfEyp5YlqqTix9IWquBxky2G)nWTz3unYLmCQLbwKm5ulJq23BbgcmCQLbwKmq7wC6AbgcmQg3JYaT5qctgkeEHTewUue7bKdjmzyWlSLWYLIypGCA2nvJCjdNIXOvmy0syYPwgHSVNeMmCkgJwXGrlHLlfXEaBnDuAUWd7jxEbXsCtbLFjeeAgpfv4s9MAGzbVLgTmko5FdC7AbgcmQg3JYaT5qctgkeEHTewUue7bKdjmzyWlSLWYLIypGCA2nvJCjdNIXOvmy0syYPwgHSVNeMmCkgJwXGrlHLlfXEaBnDuAUWd7jxEbXsCtbL)trfU4glGsfbuoiASeZs5FdC7AbgcmQg3JYaT5qctgUXcOuraLdIYWPsr4dxaA6O0CHh2tU8AzGqYimeZgsuob1B(3axkeAiHiFmQg3JYkbv3d7daqY0rP5cpSNC5fvqHL3ryiAaPlzKSeffZ)g421cmeyunUhLbAZPPIZsnrBiYsXtpaO(EkeAiHiFmQg3JYkbv3d7daqsloKWKHbVWwcReuDpSp8HeoKWKHcHxylHvcQUh2h(qcNMDt1ixYWPymAfdgTeMCQLri77jHjdNIXOvmy0syLGQ7H9HpK0A6O0CHh2tU8AdwBW79agTmkoNoknx4H9KlV1ABBK4ErSTsLPJsZfEyp5YlfEu5YstHmgmkQmDuAUWd7jxEZgse8SGGhzmalQW)g4AbgcSsOimcghdWIkmqBoKWKHcHxylHLlfXEa5qctgg8cBjSCPi2diNMDt1ixYWPymAfdgTeMCQLri77jHjdNIXOvmy0sy5srShWwthLMl8WEYLxKHLHeqzVyjy4PhvMoknx4H9KlVbifelKrTDP2uIwIIY)g42SlGATQLryA7rmUVVRfyiWOACpkd0UfhsyYqHWlSLWYLIypGCiHjddEHTewUue7bKtZUPAKlz4umgTIbJwcto1YiK99KWKHtXy0kgmAjSCPi2dyRPJsZfEyp5YB2awhE6O0CHh2tU8cIL4MckE6O0CHh2tU8ISw1cRimefd4jthEmVsZfEyp5Y7ENuaQPW)g4QTl1McZSakgVJy7T2KjNAzesonPqOHeI8X2JQ1P5cpwjO6EyE6rFpfcnKqKpgvmcox1evZc8qLlzLGQ7H5jFE0A6O0CHh2tU8UhvRtZfE8VbUDTadbgvJ7rzG2CAAbgcmubfwEhHHObKUKrYsuumd0UVVztkeAiHiFmubfwEhHHObKUKrYsuumReuDpSpEGK((UcglhvyOckS8ocdrdiDjJKLOOygQI0cRwCu7iTHqr0QfNMwGHadvqHL3ryiAaPlzKSeffZaT77v7iTHqr0IdjmzyWlSLWkbv3d7JxXHeMmui8cBjSsq19W(WNhCAsctgofJrRyWOLWkbv3d7dsVVVBQg5sgofJrRyWOLWKtTmczRPJsZfEyp5Ylvmcox1evZc8qLl5FdC7AbgcmQg3JYaT500cmeyOckS8ocdrdiDjJKLOOygODFFZMui0qcr(yOckS8ocdrdiDjJKLOOywjO6EyF8aj99DfmwoQWqfuy5DegIgq6sgjlrrXmufPfwT4O2rAdHIOvlonjHjddEHTewjO6EyF8GdjmzOq4f2sy5srShqonjHjdNIXOvmy0sy5srShW((UPAKlz4umgTIbJwcto1YiKTAnDuAUWd7jxEdGL3ryikgWt4FdCBAbgcmQg3JYaT77PqOHeI8XOACpkReuDpSpaajT4GHgTIixA2GP2rAdHIy6O0CHh2tU8gGfvIWq80eSe(3a3MwGHaJQX9Omq7(EkeAiHiFmQg3JYkbv3d7daqsloQDK2qOiMothEmpHTCKsHNoknx4H9KlVu9OIjAbgc8FkQWfNAzGfj)BGRfyiWWPwgyrYkbv3dZtaWPlgA0kICPzdMAhPnekIPJsZfEyp5Ylo1kOgd)BGBtlWqGHtTmWIKHtLIGNaOV3cmey4uldSizLGQ7H9HRx1Id2wmMyQfqjX(WfqTw1YimCiMAbusmNMPwaLKLlQetyKCfp5RfaJTfJjMAbusSpuioBlpya00rP5cpSNC5fNAHblGc)BGBZunYLmCQLbwKm5ulJqYPPfyiWWPwgyrYWPsrWta03BbgcmCQLbwKSsq19W(WfG4ybgcmTO6T0OnObRfdNkfbp9Qw99Dt1ixYWPwgyrYKtTmcjNMwGHatlQElnAdAWAXWPsrWtVQV3cmeyunUhLbA3QfhSTymXulGsIz4uRGAm8eqTw1YimCiMAbusmhlWqGzapTIcQnezPqLlz4uPi80cmeyyOrROGAdrwku5sgovkcE61CSadbggA0kkO2qKLcvUKHtLIGNaGJfyiWmGNwrb1gISuOYLmCQue8eaCA2vBxQnfgolrrShWio1cZk9q0331cmeyunUhLbA3331Ueaz4ulmybuA13NAbuswUOsmHrYv4jxPTfkykXCrfawXzPMOnezPAlVgj99DXqJwrKlnBWu7iTHqrmDuAUWd7jxEXGxylH)nW1cmeyunUhLbAZXcmeyunUhLvcQUhMNaPKmuTT5OTl1McdNLOi2dyeNAHzLEi4qctgkeEHTewjO6EyFkbv3dpDuAUWd7jxErHWlSLW)g4AbgcmQg3JYaT5ybgcmQg3JYkbv3dZtGusgQ22C02LAtHHZsue7bmItTWSspetNPdpMVna6hE6O0CHh2tU8IbVWwc)uVPgjMAbusmx(4FdCljucUHAzeoQDK2qOi4emqy1m1cOKSCrLycJKR0wn9aGX2IXeBO4uA1cGX2IXetTakj2hUuznndgiSA6rBHTfJjMAbusClaMpga1YtpaySTymXulGsI50eBlgtm1cOKyF4ZZunYLSe59IOq4HzYPwgHSVNeMmui8cBjSCPi2dylon7QTl1McdNLOi2dyeNAHzLEi677AbgcmQg3JYaT777AxcGmm4f2sAXPPfyiWOACpkReuDpSpLGQ7H777AbgcmQg3JYaTBnDuAUWd7jxErHWlSLWp1BQrIPwaLeZLp(3a3scLGBOwgHJAhPnekcobdewntTakjlxujMWi5kTvtpaySTymXgkoLwTaySTymXulGsI9HlsNtZUA7sTPWWzjkI9agXPwywPhI((UwGHaJQX9Omq7((U2LaidfcVWwslonTadbgvJ7rzLGQ7H9PeuDpCFFxlWqGr14EugODRPJsZfEyp5YlofJrRyWOLWp1BQrIPwaLeZLp(3a3scLGBOwgHJAhPnekcobdewntTakjlxujMWi5kTvtpaySTymXgkoLwT8HlaXPzxTDP2uy4SefXEaJ4ulmR0drFFxlWqGr14EugODFFx7saKHtXy0kgmAjTMothEmFBy5KstyHNoknx4H9KlVNGCefcp(3ax1osBiuethLMl8WEYL3gQjerHWJ)nWvTJ0gcfX0rP5cpSNC5naAmrui84FdCv7iTHqrmDuAUWd7jxEnGNwrCwlcH)nW1cmeyyOrROGAdrwku5sgovkcEcaonv7iTHqr03Bbgcmd4PvuqTHilfQCjdNkfbxa0ItZMwGHadzTQfwryikgWtyG299wGHaZaEAffuBiYsHkxYaT77X2IXetTakj2hUEWPRfyiWWqJwrb1gISuOYLmq7wCA2vBxQnfgolrrShWio1cZk9q0331cmeyunUhLbA3QVxBxQnfgolrrShWio1cZk9qWXcmeyunUhLbAZXUeazyOrRiYLMnAnDuAUWd7jxEXqJwrKlnBW)g4QTl1McdNLOi2dyeNAHzLEi4ja677AbgcmQg3JYaT777AxcGmm0Ove5sZgtNPdpMVnKAmzJcC(aSMhfcOGkxoDuAUWd7jxEXGxylXLU05a]] )


end