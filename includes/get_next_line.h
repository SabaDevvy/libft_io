/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   get_next_line.h                                    :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: gsabatin <gsabatin@student.42roma.it>      +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/03/17 19:10:30 by gsabatin          #+#    #+#             */
/*   Updated: 2025/03/18 00:41:51 by gsabatin         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#ifndef GET_NEXT_LINE_H
# define GET_NEXT_LINE_H

# ifndef BUFFER_SIZE
#  define BUFFER_SIZE 420
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
