#ifndef _LINUX_FILEMON2_H
#define _LINUX_FILEMON2_H

/*
 * dentry-based persistent filesystem event notification
 *
 * (C) 2016 Thomas Schoebel-Theuer
 * (C) 2016 1&1 Internet SE
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the
 * Free Software Foundation; either version 2, or (at your option) any
 * later version.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 */

#define FM2_VERSION   "1"

#define FM2_DIR ".filemon2"

enum fm2_event {
	FM2_EV_MOUNT,
	FM2_EV_UMOUNT,
	FM2_EV_NEW = 4,
	FM2_EV_CREATE,
	FM2_EV_LINK,
	FM2_EV_MKDIR,
	FM2_EV_DELETE,
	FM2_EV_MOVED_FROM,
	FM2_EV_MOVED_TO,
	FM2_EV_OPEN = 12,
	FM2_EV_CLOSE,
	FM2_EV_READ,
	FM2_EV_WRITE,
	FM2_EV_STAT,
	FM2_EV_READDIR,
	FM2_EV_MODIFY = 20,
	FM2_EV_ATTR,
	FM2_EV_XATTR,
	FM2_EV_FLOCK = 24,
	FM2_EV_PLOCK,
	FM2_EV_REPEAT_TIMEOUT = 63,
	/* this must remain the last entry */
	FM2_EV_MAX
};

#define FM2_EV_MSK(event)				\
	(1ul << (event))

#define FM2_EV_DEFAULT_MASK					\
	(							\
	 FM2_EV_MSK(FM2_EV_CREATE)                           |	\
	 FM2_EV_MSK(FM2_EV_LINK)                             |	\
	 FM2_EV_MSK(FM2_EV_MKDIR)                            |	\
	 FM2_EV_MSK(FM2_EV_DELETE)                           |	\
	 FM2_EV_MSK(FM2_EV_MOVED_FROM)                       |	\
	 FM2_EV_MSK(FM2_EV_MOVED_TO)                         |	\
	 FM2_EV_MSK(FM2_EV_WRITE)                            |	\
	 FM2_EV_MSK(FM2_EV_MODIFY)                           |	\
	 FM2_EV_MSK(FM2_EV_ATTR)                             |	\
	 FM2_EV_MSK(FM2_EV_XATTR)                            |	\
	 0ul							\
	)

#endif /* _LINUX_FILEMON2_H */
