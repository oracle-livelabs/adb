/*
Author: Ashwin Agarwal
Contributors: Kaylien Phan
Version: 22.11

Version     Date             Author          Summary
---------------------------------------------------------
21.9        Feb-14-22       Kevin Lazarz    Added fix for LLAPEX-403 (accessible html tables) 
22.0        Feb-14-22       Kevin Lazarz    Added alt-text fix - add alt attribute to all images which do not have alt
22.1        Feb-15-22       Kevin Lazarz    Added fix for landmark issue (LLAPEX-401) and list issue (LLAPEX-400)
22.2        Feb-17-22       Kevin Lazarz    Role back LLAPEX-400 due issues in some workshops
22.3        Mar-08-22       Kevin Lazarz    Temp fix for list issues LLAPEX-400, added QA check for images missing alt-text, changed numbering for table header
22.4        Mar-30-22       Ashwin Agarwal  Added alt-text for modal images (LLAPEX-431)
22.5        Apr-1-22        Ashwin Agarwal  Created global main.js (merge main.js * main.sprint.js) - LLAPEX-440
22.6        Apr-18-22       Ashwin Agarwal  Accessibility bugs in JavaScript - anchor not in <li> - LLAPEX-400
22.7        Apr-20-22       Ashwin Agarwal  Add a static header for sprints - LLAPEX-448
22.8        May-09-22       Ashwin Agarwal  Single sourcing does not work for included files - LLAPEX-477
22.9        Jun-01-22       Ashwin Agarwal  Remove header, custom table caption (LLAPEX-418), hide expand/collapse button (LLAPEX-465), variables (LLAPEX-487), object storage URL changes (LLAPEX-488)
22.10       Jun-01-22       Ashwin Agarwal  Remove feature where the expand/collapse button disappears when there are less than or equal to 2 h2 sections
22.11       Jun-15-22       Ashwin Agarwal  Relative path incorrect for included files (LLAPEX-480)
*/

"use strict";
var showdown = "https://objectstorage.us-phoenix-1.oraclecloud.com/p/SJgQwcGUvQ4LqtQ9xGsxRcgoSN19Wip9vSdk-D_lBzi7bhDP6eG1zMBl0I21Qvaz/n/c4u02/b/common/o/redwood-hol/js/showdown.min.js";
var highlight = "https://objectstorage.us-phoenix-1.oraclecloud.com/p/SJgQwcGUvQ4LqtQ9xGsxRcgoSN19Wip9vSdk-D_lBzi7bhDP6eG1zMBl0I21Qvaz/n/c4u02/b/common/o/redwood-hol/js/highlight.min.js";
const related_path = "https://objectstorage.us-phoenix-1.oraclecloud.com/p/SJgQwcGUvQ4LqtQ9xGsxRcgoSN19Wip9vSdk-D_lBzi7bhDP6eG1zMBl0I21Qvaz/n/c4u02/b/common/o/related/";

let main = function() {
    let manifestFileName = "manifest.json";
    let expandText = "Expand All Tasks";
    let collapseText = "Collapse All Tasks";
    const copyButtonText = "Copy";
    const queryParam = "lab";
    const utmParams = [
      {
        "url": "https://signup.cloud.oracle.com",
        "inParam": "customTrackingParam",
        "outParam": "sourceType"
      },
      {
        "url": "https://myservices.us.oraclecloud.com/mycloud/signup",
        "inParam": "customTrackingParam",
        "outParam": "sourceType"
      },
      {
        "url": "https://myservices.oraclecloud.com/mycloud/signup",
        "inParam": "customTrackingParam",
        "outParam": "sourceType"
      }
    ];
    const nav_param_name = 'nav';
    const header_param_name = 'header';
    const extendedNav = { '#last': 2, '#next': 1, '#prev': -1, "#first": -2 };
    $.ajaxSetup({ cache: true });

    let manifest_global;

    $(document).ready(function() {
        let manifestFileContent;
        if (getParam("manifest")) {
            manifestFileName = getParam("manifest");
        }
        $.when(
            $.getScript(showdown, function() {
                console.log("Showdown library loaded!");
            }),
            $.getJSON(manifestFileName, function(manifestFile) {
                if (manifestFile.workshoptitle !== undefined) { // if manifest file contains a field for workshop title
                    document.getElementsByClassName("hol-Header-logo")[0].innerText = manifestFile.workshoptitle; // set title in the HTML output (DBDOC-2392)
                }
                console.log("Manifest file loaded!");


                if (getParam("manifest")) {
                    $(manifestFile.tutorials).each(function() {                        
                        if ($(this)[0].filename.indexOf("http") == -1 && $(this)[0].filename[0] !== "/") {
                            $(this)[0].filename = manifestFileName.substring(0, manifestFileName.lastIndexOf("/") + 1) + $(this)[0].filename;
                        }
                    });
                }

                // added for include feature: [DBDOC-2434] Include any file inside of Markdown before rendering
                for (let short_name in manifestFile.include) {
                    let include_fname = manifestFile.include[short_name];

                    if (include_fname.indexOf("http") == -1  && include_fname[0] !== "/") { // if the link used is relative
                        include_fname = manifestFileName.substring(0, manifestFileName.lastIndexOf("/") + 1) + include_fname;
                    }

                    $.get(include_fname, function(included_file_content) {                        
                        manifestFile.include[short_name] = {
                            'path': include_fname,
                            'content': included_file_content
                        }                        
                    });                
                }                                                                
                if (manifestFile.variables) {
                    if (!Array.isArray(manifestFile.variables)) {
                        manifestFile['variables'] = Array(manifestFile.variables);
                    }                     
                    $(manifestFile.variables).each(function(_, i) {
                        $.getJSON(i, function(variables) {
                            if (!manifestFile['variable_values']) {                                
                                manifestFile['variable_values'] = {};
                            }
                            $.extend(manifestFile['variable_values'], variables);                            
                        });
                    })                                                            
                }

                manifest_global = manifestFileContent = manifestFile; //reading the manifest file and storing content in manifestFileContent variable                
            }),            
            $.getScript(highlight, function() {
                console.log("Highlight.js loaded!");
            })
        ).done(function() {            
            init();
            let selectedTutorial = setupTutorialNav(manifestFileContent); //populate side navigation based on content in the manifestFile            
            let articleElement = document.createElement('article'); //creating an article that would contain MD to HTML converted content

            loadTutorial(articleElement, selectedTutorial, manifestFileContent, toggleTutorialNav);
            
            prepareToc(manifestFileContent);   
            setupRelatedSection(manifestFileContent);         

            setTimeout(function() {
                if (location.hash.slice(1))
                    expandSectionBasedOnHash($("li[data-unique='" + location.hash.slice(1) + "']"));

                if ($('#leftNav-toc').hasClass('scroll'))
                    $('.selected')[0].scrollIntoView(true);
            }, 1000);
        });
    });

    // specifies when to do when window is scrolled
    $(window).scroll(function() {
        // if ($('#contentBox').height() > $('#leftNav-toc').height() || ($('#leftNav-toc').height() + $('header').height()) > $(window).height()) {
        if (($('#contentBox').outerHeight() + $('header').outerHeight() + $('footer').outerHeight()) > $(window).outerHeight()) {
            $('#leftNav-toc').addClass("scroll");

            if (($(window).scrollTop() + $(window).height()) > $('footer').offset().top) { //if footer is seen
                $('#leftNav-toc').css('max-height', $('footer').offset().top - $('#leftNav-toc').offset().top);
            } else {
                $('#leftNav-toc').css('max-height', $(window).height() - $('header').height());
            }
        } else {
            $('#leftNav-toc').removeClass("scroll");
        }

        try {
            if ((document.querySelector('.selected .active').getBoundingClientRect().y + document.querySelector('.selected .active').clientHeight) > $(window).height() && $('#leftNav-toc').hasClass("scroll"))
                $('.selected .active')[0].scrollIntoView(false);
        } catch (e) {};

        let active = $('#contentBox').find('[data-unique]').first();
        $('#contentBox').find('[data-unique]').each(function() {
            if (($(this).offset().top - $(window).scrollTop() - $('header').height()) < Math.abs($(active).offset().top - $(window).scrollTop())) {
                active = $(this);
            }
        });
        $('.selected .toc .toc-item').removeClass('active');
        $('.selected .toc').find('[data-unique="' + $(active).attr('data-unique') + '"]').addClass('active');
    });

    $(window).on('hashchange load', function(e) {
        try { // if next or previous is not available then it raises exception
            let position = extendedNav[e.target.location.hash]
            if (position !== undefined)
                changeTutorial(getMDFileName(selectTutorial(manifest_global, position).filename));
        } catch (e) {};
    });

    let init = function() {
            // hide header if the url contains header=hide
            let header_param = getParam(header_param_name);
            if (header_param == 'hide') {
                $('header').hide();
                $('body').css("padding-top", "0px");
            }
            // $('.hol-Header-actions').prependTo('.hol-Header-wrap').show();
            $('.hol-Header-actions').prependTo('.hol-Header-wrap');
            $('<div id="tutorial-title"></div>').appendTo(".hol-Header-logo")[0];

            $('#openNav').click(function() {
                let nav_param = getParam(nav_param_name);
                if (!nav_param || nav_param === 'open') {
                    window.history.pushState('', '', setParam(window.location.href, nav_param_name, 'close'));
                } else if (nav_param === 'close') {
                    window.history.pushState('', '', setParam(window.location.href, nav_param_name, 'open'));
                }
                toggleTutorialNav();
            });

            $('.hol-Footer-topLink').after($(document.createElement('a')).addClass('hol-Footer-rightLink hide'));
            $('.hol-Footer-topLink').before($(document.createElement('a')).addClass('hol-Footer-leftLink hide'));
            $('#contentBox').css('min-height', $(window).height() - $('header').outerHeight() - $('footer').outerHeight());
            $('.hol-Header-actions').show('slide');            
        }
        // the main function that loads the tutorial
    let loadTutorial = function(articleElement, selectedTutorial, manifestFileContent, callbackFunc = null) {
        $.get(selectedTutorial.filename, function(markdownContent) { //reading MD file in the manifest and storing content in markdownContent variable
            console.log(selectedTutorial.filename + " loaded!");

            if (selectedTutorial.filename == 'preview' && markdownContent == "None") {
                markdownContent = window.localStorage.getItem("mdValue");
            }
            
            markdownContent = include(markdownContent, manifestFileContent.include); // added for include feature: [DBDOC-2434] Include any file inside of Markdown before rendering
            markdownContent = substituteVariables(markdownContent, manifestFileContent.variable_values); // added for variable feature
            markdownContent = singlesource(markdownContent, selectedTutorial.type); // implement show/hide feature based on the if tag (DBDOC-2430)
            markdownContent = convertBracketInsideCopyCode(markdownContent); // converts <> tags inside copy tag to &lt; and &gt; (DBDOC-2404)
            markdownContent = addPathToImageSrc(markdownContent, selectedTutorial.filename); //adding the path for the image based on the filename in manifest
            markdownContent = addPathToTypeHrefs(markdownContent); // if type is specified in the markdown, then add absolute path for it.
            markdownContent = convertSingleLineCode(markdownContent);
            markdownContent = convertCodeBlocks(markdownContent); // codeblock with multiple breaks don't render correctly, so I convert to codeblock here itself

            $(articleElement).html(new showdown.Converter({
                tables: true, //allows tables to rendered
                parseImgDimensions: true, //allows image dimension to be specified in the markdown
                metadata: true // allows metadata to be added between --- and --- tags at the top of the markdown
            }).makeHtml(markdownContent)); //converting markdownContent to HTML by using showdown plugin

            articleElement = updateOpenCloseButtonText(articleElement, manifestFileContent); // in the manifest file, you can specify task_type to specify different text
            articleElement = showRightAndLeftArrow(articleElement, manifestFileContent);
            articleElement = renderVideos(articleElement); //adds iframe to videos
            articleElement = updateH1Title(articleElement); //adding the h1 title in the Tutorial before the container div and removing it from the articleElement
            articleElement = wrapSectionTag(articleElement); //adding each section within section tag
            articleElement = wrapImgWithFigure(articleElement); //Wrapping images with figure, adding figcaption to all those images that have title in the MD
            articleElement = addPathToAllRelativeHref(articleElement, selectedTutorial.filename); //adding the path for all HREFs based on the filename in manifest
            articleElement = setH2Name(articleElement);
            articleElement = makeAnchorLinksWork(articleElement); //if there are links to anchors (for example: #hash-name), this function will enable it work
            articleElement = addTargetBlank(articleElement); //setting target for all ahrefs to _blank
            articleElement = allowCodeCopy(articleElement); //adds functionality to copy code from codeblocks
            articleElement = enableForceDownload(articleElement); // enables the force download feature (?download=1 must be mentioned at the end of the URL)
            articleElement = injectUtmParams(articleElement);
            articleElement = showTabs(articleElement, selectedTutorial.type); //show type options as tabs (DBDOC-2455)
            articleElement = highlightCodeBlock(articleElement); // highlights the code in the codeblock (DBDOC-2494)
            articleElement = addModalWindow(articleElement); // add modal window so that images open in full screen when clicked (DBDOC-2575)
            updateHeadContent(selectedTutorial, manifestFileContent.workshoptitle); //changing document head based on the manifest

            // adding link to the support forum URL in the footer if the manifest file contains it (DBDOC-2459 and DBDOC-2496)
            addGoToForumLink(manifestFileContent.support);        
            // adding social media link to the header
            // addSocialMediaLink(manifestFileContent.help, manifestFileContent.workshoptitle);
            // adding link to the Neep Help URL in the header if the manifest file contains it (DBDOC-2496)
            addNeedHelpLink(manifestFileContent.help, manifestFileContent.workshoptitle);

            if (getParam("qa") == "true") {
                articleElement = performQA(articleElement, markdownContent, manifestFileContent);
            }
        }).done(function() {
            $("main").html(articleElement); //placing the article element inside the main tag of the Tutorial template
            setTimeout(function() {
                setupContentNav(manifestFileContent, articleElement);
            }, 0); //sets up the collapse/expand button and open/close section feature

            

            //FOllowing code will make sure that landmarks have a unique title (LLAPEX-401)
            document.getElementsByTagName("header")[0].setAttribute("title", "livelabs header");
            document.getElementsByTagName("main")[0].setAttribute("title", "livelabs main");
            document.getElementsByTagName("footer")[0].setAttribute("title", "livelabs footer");
            //END of fix for landmarks

            // Following code makes tables accessible (see LLAPEX-403)
            $("table").attr("role","presentation"); //add role to table

            var i = 0;
            var tables = document.getElementsByTagName("table");
            let title = document.querySelector('title').innerText;
            let caption_start = '{: title="';

            for (i; i < tables.length; i++)
                {   
                    var table = tables[i];                    
                    var capt = table.createCaption();
                    let given_title = null;
                    let next_element = $($(tables)[i]).find('tr').last();
                    if (next_element.text().trim().startsWith(caption_start)) {                        
                        given_title = next_element.text().trim().replace(caption_start, "");
                        given_title = given_title.replace('"}', "");                        
                        $(next_element).remove();
                    }                                       
                    var tit = capt.textContent= 'Table ' + (i+1) + ': ' + (given_title || title);                    
                    table.setAttribute("role", "presentation");
                };
            // END OF TABLE ACCESSIBILITY ENHANCEMENT

            if (selectedTutorial.filename == 'preview') {
                let uploaded_images = JSON.parse(window.localStorage.getItem("imagesValue"));

                // added for showing images in preview
                if (uploaded_images !== null) {
                    $('main').find('img').each(function(i, imageFile) {
                        for (let i = 0; i < uploaded_images.length; i++) {
                            if ($(imageFile).attr('src').indexOf(uploaded_images[i].filename) >= 0) {
                                $(imageFile).attr('src', uploaded_images[i].src);
                            }
                        }
                    });
                }
            }

            if (getParam("qa") == "true") {
                dragElement(document.getElementById("qa-report"));
            } else {
                collapseSection($("#module-content h2:not(:eq(0))"), "none"); //collapses all sections by default
            }

            if (callbackFunc)
                callbackFunc();

        }).fail(function() {
            console.log(selectedTutorial.filename + ' not found! Please check that the file is available in the location provided in the manifest file.');
        });
    }

    let convertSingleLineCode = function(markdown) {
        let regex_type = new RegExp(/`{3,4}(.*?)`{3,4}/g);
        let contentToReplace = [];

        let matches;
        do {
            matches = regex_type.exec(markdown);
            if (matches === null) {
                $(contentToReplace).each(function(index, value) {
                    markdown = markdown.replace(value.replace, value.with);
                });
                return markdown;
            }

            contentToReplace.push({
                "replace": matches[0],
                "with": '`' + matches[1] + '`'
            });

        } while (matches);
    }

    //DBDOC-2591: Code blocks break when line breaks (empty lines) are added
    let convertCodeBlocks = function(markdown) {
        let regex_type = new RegExp(/`{3,}(.*?)\n([\s\S|\n]*?)`{3,}/g);
        let matches, remove, remove_space_regex;
        let contentToReplace = [];

        do {
            let pre_tag = "<pre>";
            matches = regex_type.exec(markdown);
            if (matches === null) {
                $(contentToReplace).each(function(index, value) {
                    // replace using split because the string has regex
                    markdown = markdown.split(value.replace).join(value.with);
                });
                return markdown;
            }
            // else
            remove = matches[2].substring(0, matches[2].indexOf(matches[2].trim())).replace(/\t/g, '    ');
            // remove_space_regex = new RegExp("^" + remove, "gm");

            if (matches[1].trim().length !== 0) {
                pre_tag = '<pre class="' + matches[1].trim() + '">';
            }

            let replace_with = matches[2].replace(/\t/g, '    ').split('\n');

            for (let i = 0; i < replace_with.length; i++) {
                replace_with[i] = replace_with[i].replace(remove, '');
            }
            replace_with = replace_with.join('\n');

            contentToReplace.push({
                "replace": matches[0],
                "with": pre_tag + '<code>' + replace_with.trim() + '</code></pre>'
                    // "with": pre_tag + '<code>' + matches[2].replace(/(?=[\r\n])\r?\n?/g,"\n") + '</code></pre>'
                    // "with": pre_tag + '<code>' + matches[2].replace(remove_space_regex, '').trim().replace(/\t/g, '') + '</code></pre>'
            });
        } while (matches);
    }

    // DBDOC-2575: Add ability to expand images to full screen
    let addModalWindow = function(articleElement) {
        let modalClose = $(document.createElement('span')).attr('id', 'modalClose').html("&times;");
        let modalImg = $(document.createElement('img')).attr('id', 'modalImg');
        let modalCaption = $(document.createElement('div')).attr('id', 'modalCaption');
        let modalWindow = $(document.createElement('div')).attr('id', 'modalWindow');

        $(modalWindow).append([modalCaption, modalClose, modalImg]);
        $(articleElement).append(modalWindow);

        $(articleElement).find('img').click(function() {
            $(modalImg).attr({ src: this.src, alt: this.alt });
            $(modalWindow).addClass('show');
            $(modalCaption).text(this.alt);
        })
        $(modalWindow).click(function() {
            $(modalWindow).removeClass('show');
        })

        return articleElement;
    }

    // DBDOC-2455: Support for content selectable via tabs
    let showTabs = function(articleElement, type) {
            if ($.type(type) == "object") { // if true, it means select tab needs to be added
                let div = $(document.createElement('div')).addClass('selection_tabs');
                let tab = $(document.createElement('ul')).addClass('tab');

                if (getParam("type") == false) {
                    window.history.pushState('', '', setParam(window.location.href, 'type', Object.keys(type)[0]));
                }

                $(Object.keys(type)).each(function(_, type_key) {
                    let li = $(document.createElement('li')).addClass('btn_if_' + type_key);
                    // $(li).html('<a href="' + setParam(window.location.href, 'type', type_key) + '">' + type[type_key] + '</a>');
                    $(li).html('<a href="#">' + type[type_key] + '</a>');
                    $(li).find('a').click(function() {
                        $(this).attr('href', setParam(window.location.href, 'type', type_key));
                    });
                    $(tab).append(li);

                    if (type_key == getParam("type")) {
                        $(li).find('a').addClass('active');
                    }
                });

                $(div).append(tab);
                $(articleElement).find('h2:not(:eq(0))').after(div);
                $(articleElement).find('h1').after(div);
                $(articleElement).find('.selection_tabs:not(:eq(0))').addClass('stick');
            }

            return articleElement;
        }
        // DBDOC-2494: added for syntax highlight feature. The syntax highlight feature uses the highlight.js plugin.
    let highlightCodeBlock = function(articleElement) {
        $(articleElement).find('pre:not(.nohighlighting) code').each(function(_, block) {
            hljs.highlightBlock(block);
        });
        return articleElement;
    }

    // DBDOC-2449: added for force download feature. To force download a file referenced in the link, append '?download=1' to the link.
    let enableForceDownload = function(articleElement) {
        $(articleElement).find('a[href$="?download=1"]').each(function() { // loop through each link that ends with ?download=1
            $(this).attr('download', ''); // set download attribute to the link
            $(this)[0].href = $(this)[0].href.replace('?download=1', ''); // removes ?download=1 from the link
        });
        return articleElement;
    }

    // added for include feature: [DBDOC-2434] Include any file inside of Markdown before rendering
    let include = function(markdown, include) {
        for (let short_name in include) {
            if (typeof include[short_name] !== 'object')
                continue;
            include[short_name]['content'] = addPathToImageSrc(include[short_name]['content'], include[short_name]['path']);
            markdown = markdown.split("[](include:" + short_name + ")").join(include[short_name]['content']);
        }        
        return markdown;
    }

    // added for variable substitute feature
    let substituteVariables = function(markdown, all_variables) {
        for (let variable in all_variables) {            
            markdown = markdown.split("[](var:" + variable + ")").join(all_variables[variable]);
        }
        return markdown;
    }

    let addPathToTypeHrefs = function(markdown) {
        let regex_type = new RegExp(/\[(?:.+?)\]\((&type=(\S*?))\)/g);
        let matches;

        do {
            matches = regex_type.exec(markdown);
            if (matches !== null) {
                markdown = markdown.replace(matches[1], setParam(window.location.href, "type", matches[2]));
            }
        } while (matches);

        return markdown;
    }

    let arrowClick = function() {            
        if ($(this).text() === '-') {
            $(this).next().next().fadeOut('fast', function() {
                $(window).scroll();
            });
            $(this).text('+');
        } else {
            $(this).next().next().fadeIn('fast', function() {
                $(window).scroll();
            });
            $(this).text('-');
        }
    }

    let setupRelatedSection = function(manifestFileContent) {
        // this part has been added for LLAPEX-448
        const max_related = 5;
        let related_li = [];
        if ('show_related' in manifestFileContent) { 
            let related_content;
            let tut_titles = [];
            
            for (let i = 0; i < manifestFileContent.tutorials.length; i++) {
                tut_titles[i] = manifestFileContent.tutorials[i].title.toLowerCase();
            }                        
            
            for (let i = 0; i < manifestFileContent.show_related.length; i++) {                    
                if (!('filename' in manifestFileContent.show_related[i]) || !('tags' in manifestFileContent.show_related[i]) || !('title' in manifestFileContent.show_related[i])) {
                    continue;
                }                
                $.getJSON(related_path + manifestFileContent.show_related[i]['filename'], function(content) {      
                    related_content = content;
                }).done(function() {                    
                    related_li[i] = $(document.createElement('li')).attr('id', 'related-content-' + i).css({'border-bottom': '0px', 'padding-left': '36px', 'cursor': 'default', 'background-color': 'rgb(0,0,0,0.06)'});
                    
                    let div_main = $(document.createElement('div'));
                    let a = $(document.createElement('a')).css('cursor', 'pointer');                    
                    let arrow, div;

                    $(a).click(function() {
                        $(this).prev().click();
                    });
                    $(a).append($(document.createElement('div')).text(manifestFileContent.show_related[i]['title']).css({'font-weight': '600'}));
                    $(div_main).append(a);
                    $(related_li[i]).append(div_main);                    
                    div = $(document.createElement('div')).attr('id', 'toc-related-' + i).addClass('toc');                                        
                    $(div_main).append(div);                    
                    
                    if ('state' in manifestFileContent.show_related[i] && manifestFileContent.show_related[i]['state'] === "collapsed") {
                        $(div).hide();
                        arrow = $(document.createElement('div')).addClass('arrow').text('+');
                    } else {
                        arrow = $(document.createElement('div')).addClass('arrow').text('-');
                    }
                    
                    $(arrow).css('cursor', 'pointer').click(arrowClick);
                    $(div_main).prepend(arrow);                    
                    $("#leftNav-toc ul.hol-Nav-list:first-of-type").append(related_li[i]);
         
                    // for each related workshop
                    let related_workshops = {};
                    let tags = manifestFileContent.show_related[i]['tags'];
                    $(tags).each(function(_, tag) {                    
                        related_workshops = {...related_workshops, ...related_content[tag]};
                    });                                              
                
                    let filtered_workshops = {};
                    
                    for (let j = 0; j < Object.keys(related_workshops).length; j++) {
                        if (manifestFileContent.workshoptitle.toLowerCase() === Object.keys(related_workshops)[j].toLowerCase()) continue;                        
                        if ($.inArray(Object.keys(related_workshops)[j].toLowerCase(), tut_titles) != -1) continue;

                        filtered_workshops[Object.keys(related_workshops)[j]] = related_workshops[Object.keys(related_workshops)[j]];                        
                    }                                    
                    
                    let filter = Object.keys(filtered_workshops).sort(() => Math.random() - Math.random()).slice(0, max_related);

                    $(filter).each(function(_, f) {
                        let ul = document.createElement('ul');
                        let li = $(document.createElement('li')).addClass('toc-item').text(f);                        
                        $(li).wrapInner('<a href="' + filtered_workshops[f] + '"></a>');
                        $(ul).append(li);
                        $(ul).appendTo(div);     
                    });
                });                       
            }                        
        }      
    }

    let prepareToc = function(manifestFileContent) {
        let h2_regex = new RegExp(/^##\s(.+)*/gm);
        let h2s_list = [];
        let matches;        

        $(manifestFileContent.tutorials).each(function(i, tutorial) {
            let ul;
            let div = document.createElement('div');
            $(div).attr('id', 'toc' + i).addClass('toc');

            $.get(tutorial.filename, function(markdownContent) { //reading MD file in the manifest and storing content in markdownContent variable
                if (tutorial.filename == 'preview' && markdownContent == "None") {
                    markdownContent = window.localStorage.getItem("mdValue");
                }
                markdownContent = include(markdownContent, manifestFileContent.include);
                markdownContent = singlesource(markdownContent, tutorial.type);

                do {
                    matches = h2_regex.exec(markdownContent);

                    if (matches !== null) {
                        ul = document.createElement('ul');
                        $(ul).append($(document.createElement('li')).addClass('toc-item').text(matches[1].replace(/\**/g, '').replace(/\##/g, '')).attr('data-unique', alphaNumOnly(matches[1])));
                        $(ul).click(function() {
                            if ($(this).parent().parent().parent().hasClass('selected')) {
                                location.hash = alphaNumOnly($(this).text());
                                expandSectionBasedOnHash($(this).find('li').attr('data-unique'));
                            } else {
                                changeTutorial(getMDFileName(tutorial.filename), alphaNumOnly($(this).text()));
                            }

                        });

                        // fix added for LLAPEX-400
                        $(ul).each(function() {
                            if(tutorial !== selectTutorial(manifestFileContent)) {
                                let li = $(this).find('li')[0];                            
                                $(li).wrapInner('<a style="' + tutorial.tocstyle + '" href="' + unescape(setParam(window.location.href, queryParam, getMDFileName(tutorial.filename))) + '#' + $(li).attr('data-unique') + '"></a>');
                            }            
                        });
                        $(ul).appendTo(div);
                    }
                } while (matches);
                
            });
            
            $('.hol-Nav-list li')[i].append(div);
        });                
          
        setTimeout(function() {
            let anchorItem = $('.selected li[data-unique="' + location.hash.slice(1) + '"]');
            if (anchorItem.length !== 0)
                $(anchorItem)[0].click();
        }, 1000);                
        $(".hol-Nav-list>li").wrapInner("<div></div>")
        
        $(".hol-Nav-list>li>div").prepend($(document.createElement('div')).addClass('arrow').text('+'));
        
        $('.hol-Nav-list > li > div .arrow').click(arrowClick);

        $('.selected div.arrow').text('-');
        $('.hol-Nav-list > li:not(.selected) .toc').hide();
                            
    }

    let toggleTutorialNav = function() {
        let nav_param = getParam(nav_param_name);

        if (!nav_param || nav_param === 'open') {
            $('.hol-Nav-list > li:not(.selected)').attr('tabindex', '0');
            $('#leftNav-toc, #leftNav, #contentBox').addClass('open').removeClass('close');
        } else if (nav_param === 'close') {
            $('.hol-Nav-list > li:not(.selected)').attr('tabindex', '-1');
            $('#leftNav-toc, #leftNav, #contentBox').addClass('close').removeClass('open');
        }
        setTimeout(function() {
            $(window).scroll();
        }, 100);
    }


    /* The following functions creates and populates the tutorial navigation.*/
    let setupTutorialNav = function(manifestFileContent) {
        let div = $(document.createElement('div')).attr('id', 'leftNav-toc');
        let ul = $(document.createElement('ul')).addClass('hol-Nav-list');

        $(manifestFileContent.tutorials).each(function(i, tutorial) {
            let file_name = getMDFileName(tutorial.filename);

            $(document.createElement('li')).each(function() {
                $(this).click(function(e) {
                    if (!$(e.target).hasClass('arrow') && !$(e.target).hasClass('toc-item') && !$(e.target).hasClass('toc-item active')) {
                        if ($(e.target).parent().parent().hasClass('selected') || $(e.target).hasClass('selected')) {
                            try {
                                $('.selected .arrow').click();
                            } catch (e) {}
                        } else {
                            changeTutorial(file_name);
                        }
                    }
                });
                $(this).attr('id', getLabNavID(file_name));
                //The title specified in the manifest appears in the side nav as navigation
                // $(this).text(tutorial.title).wrapInner("<span></span>");
                $(this).text(tutorial.title).wrapInner("<a href=\"" + unescape(setParam(window.location.href, queryParam, getMDFileName(tutorial.filename))) + "\"><div></div></a>");
                $(this).appendTo(ul);

                /* for accessibility */
                $(this).keydown(function(e) {
                    if (e.keyCode === 13 || e.keyCode === 32) { //means enter and space
                        e.preventDefault();
                        changeTutorial(file_name);
                    }
                });
                /* accessibility code ends here */
            });
        });

        $(ul).appendTo(div);
        $(div).appendTo('#leftNav');        
        return selectTutorial(manifestFileContent);
    }

    let getMDFileName = function(file_name) {
        return file_name.split('/')[file_name.split('/').length - 1].replace('.md', '');
    }

    let getLabNavID = function(file_name, prefix = 'tut-') {
        return prefix + getMDFileName(file_name.toString()).replace(/[\(\)]+?/g, '').replace('.md', '');
    }

    let selectTutorial = function(manifestFileContent, position = 0) {
        $('#' + getLabNavID(getParam(queryParam))).addClass('selected'); //add class selected to the tutorial that is selected by using the ID
        $('.selected').find('a').contents().unwrap(); // remove hyperlink from "selected" lab
        $('.selected').unbind('keydown');

        if (position === -2) return manifestFileContent.tutorials[0];
        if (position === 2) return manifestFileContent.tutorials[manifestFileContent.tutorials.length - 1];

        //find which tutorial in the manifest file is selected
        for (var i = 0; i < manifestFileContent.tutorials.length; i++) {
            if (getParam(queryParam) === getMDFileName(manifestFileContent.tutorials[i].filename))
                return manifestFileContent.tutorials[i + position];
        }

        // if old link style URL is used (for example: ?labs=short-tutorial-title)
        // remove this condition after old style link is removed
        for (var i = 0; i < manifestFileContent.tutorials.length; i++) {
            if (getParam(queryParam) === createShortNameFromTitle(manifestFileContent.tutorials[i].title)) {
                changeTutorial(getMDFileName(manifestFileContent.tutorials[i].filename), window.location.hash.substr(1));
                return;
            }
        }
        // until here

        //if no title has selected class, selected class is added to the first class
        $('.hol-Nav-list').find('li:eq(0)').addClass("selected");
        return manifestFileContent.tutorials[0 + position]; //return the first tutorial is no tutorial is matches
    }

    /* Setup toc navigation and tocify */
    let setupTocNav = function() {
        $(".hol-Nav-list .selected").wrapInner("<div tabindex='0'></div>")
        $(".hol-Nav-list .selected div").prepend($(document.createElement('div')).addClass('arrow').text('+'));
        $(".hol-Nav-list .selected").unbind('click');

        $(".hol-Nav-list .selected > div").click(function(e) {
            if ($('.selected div.arrow').text() === '-') {
                $('#toc').fadeOut('fast');
                $('.selected div.arrow').text('+');
            } else {
                $('#toc').fadeIn('fast');
                $('.selected div.arrow').text('-');
            }
        });

        /* for accessibility */
        $(".hol-Nav-list .selected > div").keydown(function(e) {
            if (e.keyCode === 13 || e.keyCode === 32) { //means enter and space
                e.preventDefault();
                $(this).click()
            }
        });
        /* accessibility code ends here */

        $(window).scroll();
        $('#toc').appendTo(".hol-Nav-list .selected");
        $('.selected div.arrow').click();
    }

    /* The following function performs the event that must happen when the lab links in the navigation is clicked */
    let changeTutorial = function(file_name, anchor = "") {
        if (anchor !== "") anchor = '#' + anchor;
        location.href = unescape(setParam(window.location.href, queryParam, file_name) + anchor);
    }

    /*the following function changes the path of images as per the path of the MD file.
    This ensures that the images are picked up from the same location as the MD file.
    The manifest file can be in any location.*/
    let addPathToImageSrc = function(markdownContent, myUrl) {
            let imagesRegExp = new RegExp(/!\[.*?\]\((.*?)\)/g);
            let contentToReplace = []; // content that needs to be replaced
            let matches;

            myUrl = myUrl.substring(0, myUrl.lastIndexOf('/') + 1); //removing filename from the url

            do {
                matches = imagesRegExp.exec(markdownContent);
                if (matches === null) {
                    $(contentToReplace).each(function(index, value) {
                        markdownContent = markdownContent.replace(value.replace, value.with);
                    });
                    return markdownContent;
                }

                // if (myUrl.indexOf("/") !== 1) {
                matches[1] = matches[1].split(' ')[0];                
                if (matches[1].indexOf("http") === -1 && matches[1][0] !== "/") {                    
                    contentToReplace.push({
                        "replace": '(' + matches[1],
                        /* "with": '(' + myUrl + matches[1] TMM: changed 10/6/20*/
                        "with": '(' + myUrl + matches[1].trim()
                    });
                }
                // }
            } while (matches);
        }
        /* The following function adds the h1 title before the container div. It picks up the h1 value from the MD file. */
    let updateH1Title = function(articleElement) {
            $('#tutorial-title').text("\t\t›\t\t" + $(articleElement).find('h1').text());
            // $(articleElement).find('h1').remove(); //Removing h1 from the articleElement as it has been added to the HTML file already
            return articleElement;
        }
        /* This function picks up the entire converted content in HTML, and break them into sections. */
    let wrapSectionTag = function(articleElement) {
            $(articleElement).find('h2').each(function() {
                $(this).nextUntil('h2').andSelf().wrapAll('<section></section>');
            });
            return articleElement;
        }
        /* Wrapping all images in the article element with Title in the MD, with figure tags, and adding figcaption dynamically.
        The figcaption is in the format Description of illustration [filename].
        The image description files must be added inside the files folder in the same location as the MD file.*/
    let wrapImgWithFigure = function(articleElement) {
            $(articleElement).find("img").on('load', function() {
                if ($(this)[0].width > 100 || $(this)[0].height > 100 || $(this).attr("title") !== undefined) { // only images with title or width or height > 100 get wrapped (DBDOC-2397)
                    $(this).wrap("<figure></figure>"); //wrapping image tags with figure tags
                   
                }

                //Add role attribute to all images that do not have an alt attribute
                if ($(this).attr("alt").length <1 || (!$(this).attr("alt")) || $(this).attr("alt") == '' || $(this).attr("alt") == undefined || $(this).attr("alt") == 0) {
                     // $(this).attr("role","presentation"); ALternative solution
                     $(this).attr("alt","The content is described above.") ;
                }

            });
            return articleElement;
        }
        /*the following function changes the path of the HREFs based on the absolute path of the MD file.
        This ensures that the files are linked correctly from the same location as the MD file.
        The manifest file can be in any location.*/
    let addPathToAllRelativeHref = function(articleElement, myUrl) {
            if (myUrl.indexOf("/") !== -1) {
                myUrl = myUrl.replace(/\/[^\/]+$/, "/"); //removing filename from the url
                $(articleElement).find('a').each(function() {
                    if ($(this).attr("href").indexOf("http") === -1 && $(this).attr("href")[0] !== "/" && $(this).attr("href").indexOf("?") !== 0 && $(this).attr("href").indexOf("#") !== 0) {
                        $(this).attr("href", myUrl + $(this).attr("href"));
                    }
                });
            }
            return articleElement;
        }
        /* the following function makes anchor links work by adding an event to all href="#...." */
    let makeAnchorLinksWork = function(articleElement) {
            $(articleElement).find('a[href^="#"]').each(function() {
                let href = $(this).attr('href');
                if (href !== "#") { //eliminating all plain # links
                    $(this).click(function() {
                        expandSectionBasedOnHash(href.split('#')[1]);
                    });
                }
            });
            return articleElement;
        }
        /*the following function sets target for all HREFs to _blank */
    let addTargetBlank = function(articleElement) {
            $(articleElement).find('a').each(function() {
                if ($(this).attr('href').indexOf("http") === 0 && $(this).attr('href').indexOf("&type=") == -1) //ignoring # hrefs
                    $(this).attr('target', '_blank'); //setting target for ahrefs to _blank
            });
            return articleElement;
        }
        /* Sets the title, contentid, description, partnumber, and publisheddate attributes in the HTML page.
        The content is picked up from the manifest file entry*/
    let updateHeadContent = function(tutorialEntryInManifest, workshoptitle) {
        (workshoptitle !== undefined) ?
        document.title = workshoptitle + " | " + tutorialEntryInManifest.title:
            document.title = tutorialEntryInManifest.title;

        const metaProperties = [{
            name: "contentid",
            content: tutorialEntryInManifest.contentid
        }, {
            name: "description",
            content: tutorialEntryInManifest.description
        }, {
            name: "partnumber",
            content: tutorialEntryInManifest.partnumber
        }, {
            name: "publisheddate",
            content: tutorialEntryInManifest.publisheddate
        }];
        $(metaProperties).each(function(i, metaProp) {
            if (metaProp.content) {
                let metaTag = document.createElement('meta');
                $(metaTag).attr(metaProp).prependTo('head');
            }
        });
    }

    /* Add the Go to forum link in the footer (DBDOC-2459 and DBDOC-2496) */
    let addGoToForumLink = function(support) {
        const support_text = "Go to forum";
        if (support !== undefined) {
            // the Need Help? URL is taken from the manifest file (key is support)
            let need_help = $(document.createElement('li')).append($(document.createElement('a')).attr({ 'href': support, 'target': '_blank' }).text(support_text));
            $('.footer-links').append(need_help);
        }
    }

    /* Add the Need Help link in the header (DBDOC-2459 and DBDOC-2496) */
    let addNeedHelpLink = function(help, wtitle) {
        const subject = "Question about workshop: " + wtitle;
        const help_text = "Need help? Send us an email.";
        if (help !== undefined) {
            // the Need Help? URL is taken from the manifest file (key is help)
            let need_help = $(document.createElement('a')).attr({ 'href': 'mailto:' + help + '?subject=' + subject, 'title': help_text, 'id': 'need_help', 'tabindex': '0' }).text('?');
            $('header .hol-Header-wrap').append(need_help);

            // let need_help_div = $(document.createElement('div')).attr({ 'href': 'mailto:' + help + '?subject=' + subject, 'title': help_text, 'id': 'need_help', 'tabindex': '0' }).text('?');
            // $('div#container').append(need_help_div);
        }
    }

    /* Add the Social Media link in the header */
    // let addSocialMediaLink = function(help, wtitle) {   
    //     let url_to_share = (window.location != window.parent.location) ? document.referrer: document.location.href; 
    //     console.log(url_to_share);
    //     console.log(window.parent.location);
    //     // Share Workshop on Facebook
    //     let fb = $(document.createElement('a')).attr({ 
    //         'href': 'https://facebook.com', 
    //         'title': "Share on Facebook", 
    //         'target': '_blank', 
    //         'id': 'need_help', 
    //         'tabindex': '1' 
    //     }).text('F');        
    //     $('header .hol-Header-wrap').append(fb);

    //     let linkedin = $(document.createElement('a')).attr({ 
    //         'href': 'https://linkedin.com', 
    //         'title': "Share on LinkedIn", 
    //         'target': '_blank', 
    //         'id': 'need_help', 
    //         'tabindex': '2' 
    //     }).text('I');        
    //     $('header .hol-Header-wrap').append(linkedin);

    //     let twitter = $(document.createElement('a')).attr({ 
    //         'href': 'https://twitter.com', 
    //         'title': "Share on Twitter", 
    //         'target': '_blank', 
    //         'id': 'need_help', 
    //         'tabindex': '2' 
    //     }).text('T');        
    //     $('header .hol-Header-wrap').append(twitter);
    // }

    /* Enables collapse/expand feature for the steps */
    let setupContentNav = function(manifestFileContent, articleElement) {        
            //adds the expand collapse button before the second h2 element
            $("#module-content h2:eq(1)")
                .before('<button id="btn_toggle" class="hol-ToggleRegions plus">' + expandText + '</button>')
                .prev().on('click', function(e) {
                    ($(this).text() === expandText) ? expandSection($("#module-content h2:not(:eq(0))"), "show"): collapseSection($("#module-content h2:not(:eq(0))"), "hide");
                    changeButtonState(); //enables the expand all parts and collapse all parts button

                });
            //enables the feature that allows expand collapse of sections
            $("#module-content h2:not(:eq(0))").click(function(e) {
                ($(this).hasClass('plus')) ? expandSection(this, "fade"): collapseSection(this, "fade");
                changeButtonState();
            });
            /* for accessibility */
            $("#module-content h2:not(:eq(0))").attr('tabindex', '0');
            $('#module-content h2:not(:eq(0))').keydown(function(e) {
                if (e.keyCode === 13 || e.keyCode === 32) { //means enter and space
                    e.preventDefault();
                    if ($(this).hasClass('plus'))
                        expandSection($(this), "fade");
                    else
                        collapseSection($(this), "fade");
                }
            });
            /* accessibility code ends here */

            // code to hide expand/collapse button
            let hide_expand_button = selectTutorial(manifestFileContent).hide_button || manifestFileContent.hide_button;                
            if (hide_expand_button ==  "true" || hide_expand_button == "yes") {
                $('#btn_toggle').hide();
            }

            window.scrollTo(0, 0);
        }
        /* Expands the section */
    let expandSection = function(anchorElement, effect) {
            if (effect === "show") {
                $(anchorElement).nextUntil("#module-content h1, #module-content h2").show('fast', function() {
                    $(window).scroll();
                }); //expand the section incase it is collapsed
            } else if (effect === "fade") {
                $(anchorElement).nextUntil("#module-content h1, #module-content h2").fadeIn('fast', function() {
                    $(window).scroll();
                });
            }
            $(anchorElement).addClass("minus");
            $(anchorElement).removeClass("plus");
        }
        /* Collapses the section */
    let collapseSection = function(anchorElement, effect) {
            if (effect === "hide") {
                $(anchorElement).nextUntil("#module-content h1, #module-content h2").hide('fast', function() {
                    $(window).scroll();
                }); //collapses the section incase it is expanded
            } else if (effect === "fade") {
                $(anchorElement).nextUntil("#module-content h1, #module-content h2").fadeOut('fast', function() {
                    $(window).scroll();
                });
            } else if (effect == "none") {
                $(anchorElement).nextUntil("#module-content h1, #module-content h2").attr('style', 'display:none;');
            }
            $(anchorElement).addClass('plus');
            $(anchorElement).removeClass('minus');
        }
        /* Detects the state of the collapse/expand button and changes it if required */
    let changeButtonState = function() {
            if ($("#module-content h2.minus").length <= $("#module-content h2.plus").length) { //if all sections are expanded, it changes text to expandText
                $('#btn_toggle').text(expandText);
                $("#btn_toggle").addClass('plus');
                $("#btn_toggle").removeClass('minus');
            } else {
                $('#btn_toggle').text(collapseText);
                $("#btn_toggle").addClass('minus');
                $("#btn_toggle").removeClass('plus');
            }
        }
        /* Expands section on page load based on the hash. Expands section when the leftnav item is clicked */
    let expandSectionBasedOnHash = function(itemName) {
        let anchorElement = $('div[name="' + itemName + '"]').next(); //anchor element is always the next of div (eg. h2 or h3)
        if ($(anchorElement).hasClass('hol-ToggleRegions')) //if the next element is the collpase/expand button
            anchorElement = $(anchorElement).next();
        try {
            if (anchorElement[0].tagName !== 'H2') {
                anchorElement = $(anchorElement).siblings('h2');
            }

            if ($(anchorElement).hasClass('minus') || $(anchorElement).hasClass('plus'))
                expandSection(anchorElement, "fade");
            $(anchorElement)[0].scrollIntoView();
            window.scrollTo(0, window.scrollY - $('.hol-Header').height());
            changeButtonState();
        } catch (e) {};
    }

    // this function higlights the text when the copy button is clicked
    // let selectElement = function(elements) {
    //     let sel, range, el = elements;
    //     if (window.getSelection && document.createRange) { //Browser compatibility
    //         sel = window.getSelection();
    //         window.setTimeout(function(){
    //             range = document.createRange(); //range object
    //             range.selectNodeContents(el); //sets Range
    //             sel.removeAllRanges(); //remove all ranges from selection
    //             sel.addRange(range); //add Range to a Selection.
    //         }, 1);

    //         window.setTimeout(function() {
    //             sel.removeAllRanges();
    //         }, 4000);
    //     }
    // }

    // this function higlights the text when the copy button is clicked
    let selectElement = function(elements) {
        $(elements).addClass('code-highlight');

        window.setTimeout(function() {
            $(elements).removeClass('code-highlight');
        }, 2000);
    }

    /* adds code copy functionality in codeblocks. The code that needs to be copied needs to be wrapped in <copy> </copy> tag */
    let allowCodeCopy = function(articleElement) {
            $(articleElement).find('pre code').each(function() {
                if ($(this).text().indexOf('<copy>') >= 0) {
                    let code = $(document.createElement('code')).html($(this).text());
                    $(this).html($(code).html());
                }

                if ($(this).has('copy').length >= 1) {
                    $(this).find('copy').contents().unwrap().wrap('<span class="copy-code">');
                    $(this).before('<button class="copy-button" title="Copy text to clipboard">' + copyButtonText + '</button>');
                }
            });
            $(articleElement).find('.copy-button').click(function() {
                selectElement($(this).next().find('.copy-code'));

                let copyText = $(this).next().find('.copy-code').map(function() {
                    return $(this).text().trim();
                }).get().join('\n');
                let dummy = $('<textarea>').val(copyText).appendTo(this).select();
                document.execCommand('copy');
                $(dummy).remove();
                $(this).parent().animate({
                    opacity: 0.2
                }).animate({
                    opacity: 1
                });
            });
            return articleElement;
        }
        /* adds iframe to videos so that it renders in the same page.
        The MD code should be in the format [](youtube:<enter_video_id>) for it to render as iframe. */
    let renderVideos = function(articleElement) {
            $(articleElement).find('a[href^="youtube:"]').each(function() {
                $(this).after('<div class="video-container"><iframe title="video iframe" src="https://www.youtube.com/embed/' + $(this).attr('href').split(":")[1] + '" frameborder="0" allowfullscreen></div>');
                $(this).remove();
            });
            return articleElement;
        }
        /* remove all content that is not of type specified in the manifest file. Then remove all if tags.*/
    let singlesource = function(markdownContent, type) {
            let ifTagRegExp = new RegExp(/<\s*if type="([^>]*)">([\s\S|\n]*?)<\/\s*if>/gm);
            let contentToReplace = []; // content that needs to be replaced

            if (getParam("type") !== false) {
                type = getParam("type");
            } else if ($.type(type) == 'object') {
                type = Object.keys(type)[0];
            }

            if ($.type(type) !== 'array')
                type = Array(type);

            let matches;
            do {
                matches = ifTagRegExp.exec(markdownContent);
                if (matches === null) {
                    $(contentToReplace).each(function(index, value) {
                        markdownContent = markdownContent.replace(value.replace, value.with);
                    });
                    return markdownContent;
                }
                // convert if type to array
                let all_types = matches[1].split(' '),
                    matchFound = false;

                for (let i = 0; i < all_types.length && !matchFound; i++) {
                    if ($.inArray(all_types[i], type) >= 0) { // check if type specified matches content
                        matchFound = true;
                    }
                }

                // replace with blank if type doesn't match
                // replace with text without if tag (if any if type matches)
                (!matchFound) ?
                contentToReplace.push({ "replace": matches[0], "with": '' }):
                    contentToReplace.push({ "replace": matches[0], "with": matches[2] });

            } while (matches);
        }
        /* converts < > symbols inside the copy tag to &lt; and &gt; */
    let convertBracketInsideCopyCode = function(markdownContent) {
            let copyRegExp = new RegExp(/<copy>([\s\S|\n]*?)<\/copy>/gm);

            markdownContent = markdownContent.replace(copyRegExp, function(code) {
                code = code.replace('<copy>', '');
                code = code.replace('</copy>', '');
                code = code.replace(/</g, '&lt;');
                code = code.replace(/>/g, '&gt;');
                return '<copy>' + code.trim() + '</copy>';
            });

            return markdownContent;
        }
        /* injects tracking code into links specified in the utmParams variable */
    let injectUtmParams = function(articleElement) {
            let currentUrl = window.location.href;
            $(utmParams).each(function(index, item) {
                let inParamValue = getParam(item.inParam);
                if (inParamValue) {
                    $(articleElement).find('a[href*="' + item.url + '"]').each(function() {
                        let targetUrl = $(this).attr('href');
                        $(this).attr('href', unescape(setParam(targetUrl, item.outParam, inParamValue)));
                    });
                }
            });

            /* hack for manual links like this ?lab=xx. Should be removed later. */
            $(utmParams).each(function(index, item) {
                let inParamValue = getParam(item.inParam);
                if (inParamValue) {
                    $(articleElement).find('a[href*="?' + queryParam + '="]').each(function() {
                        let targetUrl = $(this).attr('href') + '&' + item.inParam + '=' + inParamValue;
                        $(this).attr('href', unescape(targetUrl));
                    });
                }
            });
            /* remove till here */
            return articleElement;
        }
        /* set the query parameter value  */
    let setParam = function(url, paramName, paramValue) {
            let onlyUrl = (url.split('?')[0]).split('#')[0];
            let params = url.replace(onlyUrl, '').split('#')[0];
            let hashAnchors = url.replace(onlyUrl + params, '');
            hashAnchors = "";

            let existingParamValue = getParam(paramName);
            if (existingParamValue) {
                return onlyUrl + params.replace(paramName + '=' + existingParamValue, paramName + '=' + paramValue) + hashAnchors;
            } else {
                if (params.length === 0 || params.length === 1) {
                    return onlyUrl + '?' + paramName + '=' + paramValue + hashAnchors;
                }
                return onlyUrl + params + '&' + paramName + '=' + paramValue + hashAnchors;
            }
        }
        /* get the query parameter value */
    let getParam = function(paramName) {
            let params = window.location.search.substring(1).split('&');
            for (var i = 0; i < params.length; i++) {
                if (params[i].split('=')[0] == paramName) {
                    return params[i].split('=')[1];
                }
            }
            return false;
        }
        /* The following function creates shortname from title */
    let createShortNameFromTitle = function(title) {
        if (!title) {
            console.log("The title in the manifest file cannot be blank!");
            return "ErrorTitle";
        }
        const removeFromTitle = ["-a-", "-in-", "-of-", "-the-", "-to-", "-an-", "-is-", "-your-", "-you-", "-and-", "-from-", "-with-"];
        const folderNameRestriction = ["<", ">", ":", "\"", "/", "\\\\", "|", "\\?", "\\*", "&", "\\.", ","];
        let shortname = title.toLowerCase().replace(/ /g, '-').trim().substr(0, 50);
        $.each(folderNameRestriction, function(i, value) {
            shortname = shortname.replace(new RegExp(value, 'g'), '');
        });
        $.each(removeFromTitle, function(i, value) {
            shortname = shortname.replace(new RegExp(value, 'g'), '-');
        });
        if (shortname.length > 40) {
            shortname = shortname.substr(0, shortname.lastIndexOf('-'));
        }
        return shortname;
    }


    let updateOpenCloseButtonText = function(articleElement, manifestFileContent) {        
        let task_type = selectTutorial(manifestFileContent).task_type || manifestFileContent.task_type;        
        if (task_type) {
            const default_task_type = "Tasks";
            task_type = task_type.trim();
            collapseText = collapseText.replace(default_task_type, task_type);
            expandText = expandText.replace(default_task_type, task_type);            
        }    
        return articleElement;
    }

    let showRightAndLeftArrow = function(articleElement, manifestFileContent) {
        let next_page = selectTutorial(manifestFileContent, extendedNav['#next']);
        let prev_page = selectTutorial(manifestFileContent, extendedNav['#prev']);


        if (next_page !== undefined) {
            $('.hol-Footer-rightLink').removeClass('hide').addClass('show').attr({ 'href': unescape(setParam(window.location.href, queryParam, getMDFileName(next_page.filename))), 'title': 'Next' }).text('Next');
        }
        if (prev_page !== undefined) {
            $('.hol-Footer-leftLink').removeClass('hide').addClass('show').attr({ 'href': unescape(setParam(window.location.href, queryParam, getMDFileName(prev_page.filename))), 'title': 'Previous' }).text('Previous');
        }
        return articleElement;
    }

    let setH2Name = function(articleElement) {

        $(articleElement).find('h2').each(function() {
            $(this).before($(document.createElement('div')).attr({
                'name': alphaNumOnly($(this).text()),
                'data-unique': alphaNumOnly($(this).text())
            }));
        });
        return articleElement;
    }

    let alphaNumOnly = function(text) { return text.replace(/[^[A-Za-z0-9:?\(\)]+?/g, ''); }


    // QA part of the code
    let performQA = function(articleElement, markdownContent, manifestFileContent) {
        let error_div = $(document.createElement('div')).attr('id', 'qa-report').html("<div id='qa-reportheader'></div><div id='qa-reportbody'><ol></ol></div>");
        const more_info = "Please see <a href='https://oracle.github.io/learning-library/sample-livelabs-templates/create-labs/labs/workshops/freetier/?lab=3a-labs-misc-develop-content-features' target='_blank'>using the LiveLabs template</a> for more information.";

        let urlExists = function(url, callback) {
            $.ajax({
                type: 'HEAD',
                url: url,
                success: function() {
                    callback(true);
                },
                error: function() {
                    callback(false);
                }
            });
        }

        let add_issue = function(error_msg, error_type = "", follow_id = false) {
            if (follow_id) {
                $(error_div).find('ol').append("<li class=" + error_type + ">" + error_msg + " <small onclick=\"window.scrollTo({top:$('." + follow_id + "').offset().top - ($('header').outerHeight() + 10), behavior: 'smooth'});\">(show)</small></li>");
            } else {
                $(error_div).find('ol').append("<li class=" + error_type + ">" + error_msg + "</li>");
            }

        }

        let checkH1 = function(article) {
            if ($(article).find('h1').length !== 1) {
                add_issue("Only a single title is allowed, please edit your Markdown file and remove or recast other content tagged with a single #.", "major-error");
                $(article).find('h1').addClass('error');
            }
        }

        let checkForGerundInTitle = function(manifest) {
            if(manifest.workshoptitle.indexOf("ing ") !== -1) {
                add_issue("Please use an imperative workshop title instead of a gerund.", "major-error")
            }
        }

        let checkForHtmlTags = function(markdown) {
            let count = (markdown.match(new RegExp("<a href=", "g")) || []).length;
            if (count == 1)
                add_issue("There is " + count + " occurrence of HTML (for example: &lt;a href=...&gt;) in your Markdown. Please do not embed HTML in Markdown.");
            else if (count > 1)
                add_issue("There are " + count + " occurrences of HTML (for example: &lt;a href=...&gt;) in your Markdown. Please do not embed HTML in Markdown.");
        }

        let checkSecondH2Tag = function(article) {
            if ($(article).find('h2:eq(1)').text().substr(0, 4).indexOf("Task") !== 0) {
                $(article).find('h2:eq(1)').addClass(getFollowId());
                add_issue("The second H2 tag (##) of your Markdown file should be labeled with \"Task\".", "", getFollowId());
            }
        }

        let checkImages = function(article) {
            $(article).find('img').each(function() {
                // skip the modalImg img frame from QA check
                if ($(this).attr("id") === "modalImg") {
                    return;
                }
                try {
                    // if ($(this).attr('src').split('/')[$(this).attr('src').split('/').length - 2].indexOf("images") !== 0) {
                    if ($(this).attr('src').indexOf("/images/") <= 0) {
                        add_issue("Your images must be in an <strong>images</strong> folder. Please rename the folder and update your Markdown.");
                        return false; // to break the each loop
                    }
                } catch (e) {
                    add_issue("Your images must be in an <strong>images</strong> folder. Please rename the folder and update your Markdown.");
                    return false;
                };
            });
        }

        let checkImagesAltText = function(article) {
            $(article).find('img').each(function() {
                // if ($(this).attr("alt").length <1 || (!$(this).attr("alt")) || $(this).attr("alt") == '' || $(this).attr("alt") == undefined || $(this).attr("alt") == 0) {
                try {
                if ($(this).attr('alt').length <1 || (!$(this).attr("alt")) || $(this).attr("alt") == '' || $(this).attr("alt") == undefined || $(this).attr("alt") == 0) {
                    add_issue("Please make sure that all images contain alternate text.");
                    return false;
                    }
                
                } catch (e) {
                return false;
                };
            })
        }

        let checkForCopyTag = function(article) {
            let count = 0;
            $(article).find('pre > code').each(function() {
                if ($(this).find('.copy-code').length == 0) {
                    count += 1;
                    $(this).addClass(getFollowId());
                    add_issue("You have a code block (```) without a &lt;copy&gt; tag. Please review your Markdown and make the necessary changes.", "", getFollowId());
                }
            });
        }

        let checkCodeBlockFormat = function(markdown) {
            let count = (markdown.match(/\````/g) || []).length;
            if (count == 1) {
                add_issue("Your Markdown file has " + count + " codeblock with 4 (````). This should be changed to 3 (```). Please review your Markdown and make the necessary changes.")
            } else if (count > 1) {
                add_issue("Your Markdown file has " + count + " codeblocks with 4 (````). This should be changed to 3 (```). Please review your Markdown and make the necessary changes.")
            }
        }

        let updateCount = function(article) {
            $(error_div).find('#qa-reportheader').html('Total Issues: ' + $(error_div).find('li').length);
            if (!$(error_div).find('li').length) {
                $(error_div).find('#qa-reportbody').hide();
            } else {
                $(error_div).find('#qa-reportbody').show();
                if ($(error_div).find('#qa-reportbody p').length === 0)
                    $(error_div).find('#qa-reportbody').append('<p>' + more_info + '</p>');
            }
        }

        let checkLinkExists = function(article) {
            $(article).find('a').each(function() {
                let url = $(this).attr('href');
                let url_text = $(this).text();
                urlExists(url, function(exists) {
                    if (!exists) {
                        $('a[href$="' + url + '"]').addClass('error ' + getFollowId());
                        add_issue("This URL may be broken: <a href='" + url + "' target='_blank'>" + url_text + "</a>", "major-error", getFollowId());
                        updateCount(article);
                    }
                });
            });
        }

        let checkImageExists = function(article) {
            $(article).find('img').each(function() {
                // skip the modalImg img frame from QA check
                if ($(this).attr("id") === "modalImg") {
                    return;
                }
                let url = $(this).attr('src');
                let url_text = $(this).attr('src').split('/')[$(this).attr('src').split('/').length - 1];
                urlExists(url, function(exists) {
                    if (!exists) {;
                        $('img[src$="' + url + '"]').addClass('error ' + getFollowId());
                        add_issue("The link to image <strong>" + url_text + "</strong> is broken.", "major-error", getFollowId())
                        updateCount(article);
                    }
                });
            });
        }

        let checkIfSectionExists = function(article, section_name) {
            if ($(article).find('div[name="' + alphaNumOnly(section_name) + '"]').length === 0)
                add_issue("You are missing <strong>" + section_name + "</strong> section.");
        }

        let checkIndentation = function(article) {
            $(article).find('section:not(:first-of-type)').each(function() {
                let tag_list = [];
                if ($(this).find('h2').text().toUpperCase().trim().indexOf("Task") == 0) {
                    $(this).children().each(function() {
                        tag_list.push($(this).prop('tagName'));
                    });

                    if ($.inArray("UL", tag_list) !== -1 & $.inArray("OL", tag_list) == -1) {
                        add_issue("In section <strong>" + $(this).find('h2').text() + "</strong>, your steps are not numbered. Numbered steps should follow your STEP element.", "minor-error");
                        $(this).find('h2').addClass('format-error');
                    }

                    if ($.inArray("PRE", tag_list) > $.inArray("OL", tag_list)) {
                        $(this).children('pre').addClass('format-error ' + getFollowId());
                        add_issue("Your codeblock is not indented correctly. Add spaces to indent your codeblock.", "minor-error", getFollowId());
                    }

                    $(this).find('img').each(function() {
                        if ($(this).parent().parent().prop('tagName').indexOf("LI") == -1 && $(this).parent().parent().prop('tagName').indexOf("OL") == -1 && $(this).parent().parent().prop('tagName').indexOf("UL") == -1) {
                            // $(this).parents('section').children('h2').addClass('format-error');
                            $(this).addClass('format-error ' + getFollowId());
                            add_issue("The image <strong>" + $(this).attr('src').split('/')[$(this).attr('src').split('/').length - 1] + "</strong> is not aligned with your text blocks. Add spaces to indent your image.", "minor-error", getFollowId());
                        }
                    });
                }
            });
        }

        let getFollowId = function() { return 'error_' + $(error_div).find('li').length; }

        checkH1(articleElement);
        checkForGerundInTitle(manifestFileContent);
        checkForHtmlTags(markdownContent);
        checkImages(articleElement);
        checkImagesAltText(articleElement);
        checkCodeBlockFormat(markdownContent);
        checkSecondH2Tag(articleElement);
        checkForCopyTag(articleElement);
        if (!window.location.href.indexOf("localhost") && window.location.href.indexOf("127.0.0.1")) {
            checkLinkExists(articleElement);
        }
        checkImageExists(articleElement);
        checkIfSectionExists(articleElement, "Acknowledgements");
        // checkIfSectionExists(articleElement, "See an issue?");
        checkIndentation(articleElement);
        updateCount(articleElement);

        return $(articleElement).prepend(error_div);
    }

    // picked up as it is from: https://www.w3schools.com/howto/howto_js_draggable.asp
    function dragElement(elmnt) {
        var pos1 = 0,
            pos2 = 0,
            pos3 = 0,
            pos4 = 0;
        if (document.getElementById(elmnt.id + "header")) {
            // if present, the header is where you move the DIV from:
            document.getElementById(elmnt.id + "header").onmousedown = dragMouseDown;

            $('#qa-reportheader').dblclick(function() { // this line has been added to collapse qa report body
                $('#qa-reportbody').fadeToggle();
            });

        } else {
            // otherwise, move the DIV from anywhere inside the DIV:
            elmnt.onmousedown = dragMouseDown;
        }

        function dragMouseDown(e) {
            e = e || window.event;
            e.preventDefault();
            // get the mouse cursor position at startup:
            pos3 = e.clientX;
            pos4 = e.clientY;
            document.onmouseup = closeDragElement;
            // call a function whenever the cursor moves:
            document.onmousemove = elementDrag;
        }

        function elementDrag(e) {
            e = e || window.event;
            e.preventDefault();
            // calculate the new cursor position:
            pos1 = pos3 - e.clientX;
            pos2 = pos4 - e.clientY;
            pos3 = e.clientX;
            pos4 = e.clientY;
            // set the element's new position:
            elmnt.style.top = (elmnt.offsetTop - pos2) + "px";
            elmnt.style.left = (elmnt.offsetLeft - pos1) + "px";
        }

        function closeDragElement() {
            // stop moving when mouse button is released:
            document.onmouseup = null;
            document.onmousemove = null;
        }
    }

}();

let download = function() {

    //enables download of files
    let download_file = function(filename, text) {
        let pom = document.createElement('a');
        pom.setAttribute('href', 'data:html/plain;charset=utf-8,' + encodeURIComponent(text));
        pom.setAttribute('download', filename);
        if (document.createEvent) {
            let event = document.createEvent('MouseEvents');
            event.initEvent('click', true, true);
            pom.dispatchEvent(event);
        } else {
            pom.click();
        }
    }

    $.when($('img').each(function() {
            $(this).css('max-width', '75%');
            if ($(this).attr('src').indexOf('http') == -1)
                $(this).attr('src', location.protocol + '//' + location.host + location.pathname + $(this).attr('src'));
        }),
        $('pre button').remove(),
        $('pre').attr('style', 'white-space: pre-wrap; white-space: -moz-pre-wrap; white-space: -pre-wrap; white-space: -o-pre-wrap; word-wrap: break-word; max-width: 80%;'),
        $("#module-content h2:not(:eq(0))").nextAll().show('fast'),
        $('h2').removeClass('plus minus'),
        $('#btn_toggle').remove()).done(function() {
        download_file($('.selected span').text().replace(/[^[A-Za-z0-9:?]+?/g, '') + '.html', '<html><head><link rel="stylesheet" href="https://objectstorage.us-phoenix-1.oraclecloud.com/p/SJgQwcGUvQ4LqtQ9xGsxRcgoSN19Wip9vSdk-D_lBzi7bhDP6eG1zMBl0I21Qvaz/n/c4u02/b/common/o/redwood-hol/css/style.min.css" /><link rel="shortcut icon" href="https://objectstorage.us-phoenix-1.oraclecloud.com/p/SJgQwcGUvQ4LqtQ9xGsxRcgoSN19Wip9vSdk-D_lBzi7bhDP6eG1zMBl0I21Qvaz/n/c4u02/b/common/o/redwood-hol/img/favicon.ico" /></head><body style="padding-top: 0px;">' + $('#contentBox')[0].outerHTML + '</body></html>');
    });
}