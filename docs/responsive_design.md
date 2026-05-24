# Responsive Design System

The MULKY AI TRADING COMPANION OS™ features a fully responsive UI that adapts to different screen sizes, providing an optimal experience on mobile, tablet, and desktop.

## Breakpoints

We use a simple breakpoint system to determine the current layout:
-   **Mobile:** Screen width < 650px
-   **Tablet:** Screen width >= 650px and < 1100px
-   **Desktop:** Screen width >= 1100px

This logic is encapsulated in the `lib/ui/responsive.dart` helper class.

## Layouts

### Dashboard
-   **Mobile/Tablet:** A single-column layout with the Emotional Orb at the top, followed by charts and stats cards.
-   **Desktop:** A multi-column layout. The Emotional Orb is given a dedicated column on the left (2/5ths of the screen), while the charts and stats are displayed in a scrollable column on the right (3/5ths of the screen). This makes better use of the available horizontal space.

### Other Pages
-   Other pages like the Entry Form and Journal use a single-column layout that naturally adapts to different screen widths, ensuring readability and usability on all devices. Padding and font sizes may be adjusted subtly based on the screen size to improve ergonomics.

---

> **Contact:** Mulky Malikul Dhaher — [mulkymalikuldhaher@email.com](mailto:mulkymalikuldhaher@email.com)
>
> **Disclaimer:** This project is for Education Purpose only. Risiko apapun tidak kita tanggung. (We are not responsible for any risks or damages.)
