<?php get_header(); ?>
<main id="main-content" class="interior-main"><section class="page-hero"><div class="wrap"><div class="kicker kicker-light">AGRO FOOD CHAIN / INSIGHTS</div><h1><?php echo esc_html(is_home() ? 'Insights & Updates' : get_the_archive_title()); ?></h1></div></section>
<section class="wrap posts-list">
<?php if (have_posts()): while (have_posts()): the_post(); ?>
<article class="post-card"><div class="post-date"><?php echo esc_html(get_the_date()); ?></div><h2><a href="<?php the_permalink(); ?>"><?php the_title(); ?></a></h2><p><?php the_excerpt(); ?></p><a class="text-link" href="<?php the_permalink(); ?>">Read article ↗</a></article>
<?php endwhile; the_posts_pagination(array('mid_size'=>1)); else: ?><p>No articles have been published yet.</p><?php endif; ?>
</section></main><?php get_footer(); ?>
