$(document).ready(function() {
            $('.popups a').wowwindow({
                draggable: true
            });
            $('.popups-rotate a').wowwindow({
                rotate: true,
                draggable: true
            });
            $('.popups-rotate-multiple a').wowwindow({
                rotate: true,
                rotations: 3,
                draggable: true
            });
 
            /**
             * The YouTube IFRAME doesn't work on local content,
             * so for the purposes of this demo, the 'videoIframe'
             * option has been set to false.  It is recommended to
             * keep it set to true (the default) for compatibility
             * with devices that are not Flash enabled.
             */
 
            $('a[rel=video]').wowwindow({
                draggable: true,
                height: 225,
                width: 400,
                videoIframe: false
            });
            $('a[rel=video_rotate]').wowwindow({
                draggable: true,
                rotate: true,
                height: 225,
                width: 400,
                videoIframe: false
            });
            $('a[rel=video_multi_rotate]').wowwindow({
                draggable: true,
                rotate: true,
                rotations: 3,
                height: 225,
                width: 400,
                videoIframe: false
            });
 
            $('#youtube-auto-thumbnails a').wowwindow({
                draggable: true,
                width: 480,
                height: 390,
                videoIframe: false,
                autoYouTubeThumb: 'default'
            });
        });

