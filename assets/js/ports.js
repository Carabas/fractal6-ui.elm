import MiniSearch from 'minisearch'
import { BulmaDriver, InitBulma, catchEsc } from './bulma_drivers'
import { GraphPack } from './graphpack_d3'
import { sleep } from './custom.js'

function initQuickSearch(qs, data) {
    qs.removeAll();
    qs.addAll(data);
}

const UCTX_KEY = "user_ctx";

// On load, listen to Elm!
window.addEventListener('load', _ => {
    window.ports = {
        init: (app) => {
            // Show the footbar
            //document.getElementById("footBar").style.display= "none";
            //setTimeout( function () {
            //    document.getElementById("footBar").style.display= "block";
            //}, 0.5);

            // Session Object
            var session = {
                isInit: true,
                bulmaHandlers: [],
                // Resizing
                rtime: null,
                timeout: false,
                delta: 200,
                // Graphpack
                gp: Object.create(GraphPack),

                /*** QuickSearch ***/
                // Node Quick Search
                qsn: new MiniSearch({
                    idField: 'nameid',
                    storeFields: ['nameid'],
                    fields: ['nameid', 'name', 'first_link'],
                    searchOptions: {
                        fuzzy: 0.3,
                        boost: { name: 2 },
                    },
                }),
                // User Quick Search
                qsu: new MiniSearch({
                    idField: 'username',
                    storeFields: ['username'],
                    fields: ['username', 'name'],
                    searchOptions: { fuzzy: 0.3, },
                }),
                // Label Quick Search
                qsl: new MiniSearch({
                    idField: 'id',
                    storeFields: ['id', 'name', 'color'],
                    fields: ['name'],
                    searchOptions: { fuzzy: 0.3, },
                }),
            };

            // Subscribe to Elm outgoing ports
            app.ports.outgoing.subscribe(({ action, data }) => {
                if (actions[action]) {
                    actions[action](app, session, data)
                } else {
                    console.warn(`I didn't recognize action "${action}".`)
                }
            });

        }
    }

})

// Elm outgoing Ports Actions.
// Maps actions to functions!
const actions = {
    //
    // Utils
    //
    'LOG': (app, session, message) => {
        console.log(`From Elm:`, message);
    },
    'SHOW': (app, session, id) => {
        var $e = document.getElementById(id);
        if (!$e) { return }
        $e.style.display = "";
        //$e.style.visibility = "hidden";
    },
    'HIDE': (app, session, id) => {
        var $e = document.getElementById(id);
        if (!$e) { return }
        $e.style.display = "none";
        //$e.style.visibility = "hidden";
    },
    'FIT_HEIGHT': (app, session, id) => {
        var fitElement = id => {
            // SOlved with Browser.Dom.getElement
            var $e = document.getElementById(id);
            if (!$e) { return }

            var doc_h = document.body.scrollHeight;
            var screen_h = window.innerHeight;
            var elt_h = $e.offsetHeight; // $e.clientHeight -> smaller
            var x = doc_h - elt_h; // header height (above the target)
            var h = screen_h - x; // target size tha fit in screen

            if (doc_h > screen_h) {
                $e.style.height = h + "px";
            } else {
                var rect = $e.getBoundingClientRect();
                $e.style.height = elt_h + (screen_h - (rect.top+elt_h)) + "px";
            }
            //document.getElementsByTagName('html')[0].style.overflow = "hidden"; // @debug: html overflow stay disable...
            //document.body.style.overflowY = "hidden";

            //$e.style.maxHeight = 0.8*screen_h + "px";

            //console.log("document client:", document.body.clientHeight);
            //console.log("document scroll:", document.body.scrollHeight);
            //console.log("window inner:", window.innerHeight);
            //console.log("window outer:", window.outerHeight);
            //console.log("screen:", screen.height);
            //console.log("screen avail:", screen.availHeight);
            //console.log("elt client:", $e.clientHeight);
            //console.log("elt scrol:", $e.scrollHeight);
            //console.log("elt style:", $e.style.height);
            //console.log("elt top:", $e.offsetTop);
            //console.log("elt bottom:", $e.offsetTop + $e.clientHeight);
        }

        setTimeout(() => {
            fitElement(id);
            //window.onresize = () => {
            //    session.rtime = new Date();
            //    if (session.timeout === false) {
            //        session.timeout = true;
            //        // Smooth redraw
            //        setTimeout( () => {
            //            if (new Date() - session.rtime < session.delta) {
            //                setTimeout(() => fitElement(id), session.delta);
            //            } else {
            //                session.timeout = false;
            //                fitElement(id)
            //            }
            //        }, session.delta);
            //    }
            //};
        }, 300)
    },
    'LOGERR': (app, session, message) => {
        console.warn(`Error from Elm:`, message);
    },
    'BULMA': (app, session, id) => {
        InitBulma(app, session, id);

        // Unlock tooltip (GP)
        session.gp.isFrozen = false;

        // Check if jwt token has expired
        var uctx = JSON.parse(localStorage.getItem(UCTX_KEY))
        if (uctx !== null && (uctx.expiresAt === undefined || new Date(uctx.expiresAt) < new Date())) {
            // refresh session
            app.ports.openAuthModalFromJs.send(uctx);
        }
    },
    'TOGGLE_TH': (app, session, message) => {
        var $tt = document.getElementById("themeButton_port");
        if ($tt) {
            $tt.addEventListener("click", function(){
                toggleTheme();
            });
        }
    },
    'SAVE_WINDOWPOS' : (app, session, data) => {
        localStorage.setItem("window_pos", JSON.stringify(data));
    },

    //
    // Modal
    //
    'OPEN_MODAL': (app, session, modalid) => {
        document.documentElement.classList.add('has-modal-active');
        document.getElementById("navbarTop").classList.add('has-modal-active');
        InitBulma(app, session, modalid)
    },
    'CLOSE_MODAL': (app, session, _) => {
        document.documentElement.classList.remove('has-modal-active');
        document.getElementById("navbarTop").classList.remove('has-modal-active');
        InitBulma(app, session, "")
    },
    'OPEN_AUTH_MODAL': (app, session, message) => {
        document.documentElement.classList.add('has-modal-active2');
        document.getElementById("navbarTop").classList.add('has-modal-active2');
    },
    'CLOSE_AUTH_MODAL': (app, session, message) => {
        document.documentElement.classList.remove('has-modal-active2');
        document.getElementById("navbarTop").classList.remove('has-modal-active2');
        InitBulma(app, session, "")
    },

    'RAISE_AUTH_MODAL': (app, session, uctx) => {
        app.ports.openAuthModalFromJs.send(uctx);
    },
    //
    // Quick Search
    //
    'INIT_USERSEARCH': (app, session, data) => {
        // Setup User quickSearch
        initQuickSearch(session.qsu, data);
    },
    'INIT_USERSEARCHSEEK': (app, session, data) => {
        // Setup and search
        var qs = session.qsu;
        // Setup User quickSearch
        initQuickSearch(qs, data.users);
        // And return a search result
        var res = qs.search(data.pattern, {prefix:true}).slice(0,20);
        app.ports.lookupUserFromJs_.send(res);
    },
    'INIT_LABELSEARCH': (app, session, data) => {
        // Setup User quickSearch
        initQuickSearch(session.qsl, data);
    },
    'ADD_QUICKSEARCH_NODES': (app, session, nodes) => {
        session.qsn.addAll(nodes);
    },
    'ADD_QUICKSEARCH_USERS': (app, session, users) => {
        session.qsu.addAll(users);
    },
    'REMOVE_QUICKSEARCH_NODES': (app, session, nodes) => {
        session.qsn.removeAll(nodes);
    },
    'REMOVE_QUICKSEARCH_USERS': (app, session, users) => {
        session.qsu.removeAll(users);
    },
    'SEARCH_NODES': (app, session, pattern) => {
        var qs = session.qsn;
        var nodes = session.gp.nodesDict;
        var res = qs.search(pattern, {prefix:true}).slice(0,20).map(n => {
            // Ignore Filtered Node (Owner, Member, etc)
            if (nodes[n.nameid]) {
                return nodes[n.nameid].data;
                //return {
                //    ...data,
                //    firstLink: (d.first_link)? data.first_link.username : "" }
            } else {
                return undefined
            }
        });
        app.ports.lookupNodeFromJs_.send(res.filter(x => x));
    },
    'SEARCH_USERS': (app, session, pattern) => {
        var qs = session.qsu;
        var res = qs.search(pattern, {prefix:true}).slice(0,20);
        app.ports.lookupUserFromJs_.send(res);
    },
    'SEARCH_LABELS': (app, session, pattern) => {
        var qs = session.qsl;
        var res = qs.search(pattern, {prefix:true}).slice(0,20);
        app.ports.lookupLabelFromJs_.send(res);
    },
    //
    // GraphPack
    //
    'INIT_GRAPHPACK': (app, session, data) => {
        var gp = session.gp;

        // Loading empty canvas
        if (!data.data || data.data.length == 0 ) {
            gp.isLoading = true;
            gp.init_canvas()
            return
        }

        setTimeout(() => { // to wait that layout is ready
            // Setup Graphpack
            var ok = gp.init(app, data, session.isInit);
            if (ok) {
                session.isInit = false;
                gp.zoomToNode(data.focusid, 0.5);
            }

            // Setup Node quickSearch
            initQuickSearch(session.qsn, data.data);
        }, 150);
    },
    'FOCUS_GRAPHPACK': (app, session, focusid) => {
        var $canvas = document.getElementById("canvasOrga");
        if ($canvas) {
            var gp = session.gp;
            gp.zoomToNode(focusid);
        }
    },
    'CLEAR_TOOLTIP': (app, session, message) => {
        var $canvas = document.getElementById("canvasOrga");
        if ($canvas) {
            var gp = session.gp;
            gp.clearNodeTooltip();
        }
    },
    'DRAW_GRAPHPACK' : (app, session, data) => {
        var $canvas = document.getElementById("canvasOrga");
        if ($canvas) {
            var gp = session.gp;
            gp.resetGraphPack(data.data, true, gp.focusedNode.data.nameid);
            gp.drawCanvas();
            gp.drawCanvas(true);
        }
    },
    'REMOVEDRAW_GRAPHPACK' : (app, session, data) => {
        var $canvas = document.getElementById("canvasOrga");
        if ($canvas) {
            // Remove a node
            for (var i=0; i<data.data.length; i++) {
                if (data.data[i].nameid == data.focusid) {
                    data.data.splice(i, 1);
                    break
                }
            }

            var gp = session.gp;
            gp.resetGraphPack(data.data, true, gp.focusedNode.data.nameid);
            gp.drawCanvas();
            gp.drawCanvas(true);
        }
    },
    'DRAW_BUTTONS_GRAPHPACK' : (app, session, _) => {
        var $canvas = document.getElementById("canvasOrga");
        if ($canvas) {
            var gp = session.gp;
            setTimeout( () => {
                gp.drawButtons()}, 300);
        }
    },
    //
    // User Ctx -- Localstorage
    //
    'SAVE_USERCTX' : (app, session, user_ctx) => {
        // @DEBUG: Maybe List encoder for multiple sessions ?
        if (user_ctx.roles && user_ctx.roles.length == 0) delete user_ctx.roles
        localStorage.setItem(UCTX_KEY, JSON.stringify(user_ctx.data));

        // If version is outdated, reload.
        if (user_ctx.data.client_version != "" && VERSION != "" && user_ctx.data.client_version != VERSION) {
            var loc = window.location;
            window.location = loc.protocol + '//' + loc.host + loc.pathname + loc.search;
        }

        // Update Page/Components accordingly
        app.ports.loadUserCtxFromJs.send(user_ctx.data);
    },
    'REMOVE_SESSION' : (app, session, _) => {
        localStorage.removeItem(UCTX_KEY);
        localStorage.removeItem("theme");
        localStorage.removeItem("window_pos");
        document.cookie = "jwt=; expires=Thu, 01 Jan 1970 00:00:01 GMT; Path=/";
        app.ports.loggedOutOkFromJs.send(null);
    },
    //
    // Popups
    //
    'INHERIT_WIDTH' : (app, session, target) => {
        const inheritWidth = () => {
            var $target = document.getElementById(target);
            if ($target) {
                $target.style.width = $target.parentNode.clientWidth + "px";
                return true
            }
            return false
        }
        sleep(10).then(() => {
            if (!inheritWidth()) {
                setTimeout(inheritWidth, 100);
            }
        });

    },
    'FOCUS_ON' : (app, session, target) => {
        setTimeout( () => {
            var $tt = document.getElementById(target);
            if ($tt) { $tt.focus(); }
        }, 100);
    },
    'OUTSIDE_CLICK_CLOSE' : (app, session, data) => {
        var id = data.target; // close the given target if a click occurs outside the div or if ESC is pressed
        var msg = data.msg; // automatically send the given msg to Elm

        // @debug: breaks the "close on click" event of burgers and dropdowns
        //InitBulma(app, session, id);

        const closeEvent = () => {
            app.ports[msg].send(null);
            removeClickListener();
        }

        // outside click listener
        const outsideClickListener = event => {
            if (event.target.closest("#"+id) === null) {
                // @debug; doesnt work!
                //event.stopPropagation();
                closeEvent();
            }
        }

        // Escape listener
        const escListener = event => {
            catchEsc(event, closeEvent);
        }

        // Remove the listener on close
        const removeClickListener = () => {
            document.removeEventListener('click', outsideClickListener);
            document.removeEventListener('keydown', escListener);
        }

        // add the listener
        setTimeout(() => {
            document.addEventListener('click', outsideClickListener);
            document.addEventListener('keydown', escListener);

            // add listenner to global handlers LUT to clean it on navigation
            var handlers = session.bulmaHandlers;
            handlers.push(["click", outsideClickListener, document, outsideClickListener])
            handlers.push(["keydown", escListener, document, escListener])

        }, 50);

    },
    'CLICK': (app, session, target) => {
        var elt = document.getElementById(target);
        if (elt) elt.click();
    },
    'FORCE_RELOAD': (app, session, target) => {
        window.location.reload(true);
    },
}
