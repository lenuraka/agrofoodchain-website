<?php get_header(); ?>
<main id="main-content" class="interior-main">
<?php while (have_posts()): the_post(); ?><section class="page-hero"><div class="wrap"><div class="kicker kicker-light">INSIGHTS / <?php echo esc_html(get_the_date()); ?></div><h1><?php the_title(); ?></h1></div></section>
<article class="wrap page-article"><?php the_content(); ?></article><?php endwhile; ?>
</main><?php get_footer(); ?>
