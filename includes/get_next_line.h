#ifndef GET_NEXT_LINE_H
# define GET_NEXT_LINE_H

# ifndef BUFFER_SIZE
#  define BUFFER_SIZE 1024
# endif

# include "libft.h"

typedef struct s_buffer
{
	int				fd;
	char			*buffer;
	struct s_buffer	*next;
}	t_buffer;

char	*get_next_line(int fd);
char	*get_next_line_multi(int fd);

// helpers.c
void	ft_remove_buffer(t_buffer **head, int fd);

#endif
