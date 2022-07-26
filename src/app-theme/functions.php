<?php
/**
 * Child theme functions.
 */

add_action( 'wp_enqueue_scripts', 'theme_enqueue_styles' );
function theme_enqueue_styles() {
    wp_enqueue_style( 'parent-style', get_template_directory_uri() . '-child/style.css' );
}

add_action('wp_enqueue_scripts','child_w6');
function child_w6(){
    if (is_page_template('page-home.php')) {
        wp_enqueue_script('child-script', '/wp-content/plugins/hybrid-composer/scripts/parallax.min.js');
        wp_enqueue_script('child-script-2', '/wp-content/plugins/hybrid-composer/scripts/jquery.tab-accordion.js');
        wp_enqueue_script('child-script-3', '/wp-content/plugins/hybrid-composer/scripts/jquery.magnific-popup.min.js');
        wp_enqueue_style('child-css', '/wp-content/plugins/hybrid-composer/css/content-box.css');
        wp_enqueue_style('child-css-2', '/wp-content/plugins/hybrid-composer/css/components.css');
        wp_enqueue_style('child-css-3', '/wp-content/plugins/hybrid-composer/scripts/magnific-popup.css');
    }
    wp_enqueue_style('child-css-icons', '/wp-content/plugins/hybrid-composer/admin/icons/icons.css');
}
