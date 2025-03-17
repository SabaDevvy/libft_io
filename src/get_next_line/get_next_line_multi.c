/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   get_next_line_multi.c                              :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: gsabatin <gsabatin@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/12/26 15:55:29 by gsabatin          #+#    #+#             */
/*   Updated: 2025/03/17 10:03:10 by gsabatin         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../../includes/get_next_line.h"
#include <unistd.h>
#include <stdlib.h>

static char	*ft_update_buffer(char *buffer)
{
	char	*new_buffer;
	int		i;

	i = 0;
	while (buffer[i] && buffer[i] != '\n')
		i++;
	if (!buffer[i])
	{
		free (buffer);
		return (NULL);
	}
	new_buffer = malloc(ft_strlen(buffer) - i + 1);
	if (!new_buffer)
	{
		free(buffer);
		return (NULL);
	}
	ft_strlcpy(new_buffer, &buffer[i + 1], ft_strlen(buffer) - i + 1);
	free(buffer);
	return (new_buffer);
}

static char	*ft_extract_line(char *buffer)
{
	char	*line;
	int		i;

	if (!buffer[0])
		return (NULL);
	i = 0;
	while (buffer[i] && buffer[i] != '\n')
		i++;
	if (buffer[i] == '\n')
		i++;
	line = malloc(i + 1);
	if (!line)
		return (NULL);
	ft_strlcpy(line, buffer, i + 1);
	return (line);
}

static char	*ft_handle_buffer(t_buffer *node, int fd)
{
	char	*temp;
	ssize_t	bytes_read;

	temp = malloc(BUFFER_SIZE + 1);
	if (!temp)
		return (NULL);
	bytes_read = 1;
	while (bytes_read && (!node -> buffer || !ft_strchr(node->buffer, '\n')))
	{
		bytes_read = read(fd, temp, BUFFER_SIZE);
		if (bytes_read == -1)
		{
			free(temp);
			return (NULL);
		}
		temp[bytes_read] = '\0';
		node->buffer = ft_strappend(node->buffer, temp);
		if (!node->buffer)
		{
			free(temp);
			return (NULL);
		}
	}
	free(temp);
	return (node->buffer);
}

static t_buffer	*ft_find_buffer(t_buffer **head, int fd)
{
	t_buffer	*current;
	t_buffer	*new_node;

	current = *head;
	while (current && current -> fd != fd)
		current = current -> next;
	if (current)
		return (current);
	new_node = malloc(sizeof(t_buffer));
	if (!new_node)
		return (NULL);
	new_node -> fd = fd;
	new_node -> buffer = NULL;
	new_node -> next = *head;
	*head = new_node;
	return (new_node);
}

char	*get_next_line_multi(int fd)
{
	static t_buffer	*buffer_list;
	t_buffer		*current;
	char			*line;

	if (fd < 0 || BUFFER_SIZE <= 0)
	{
		if (buffer_list)
			ft_remove_buffer(&buffer_list, fd);
		return (NULL);
	}
	current = ft_find_buffer(&buffer_list, fd);
	if (!current)
		return (NULL);
	if (!current->buffer || !ft_strchr(current->buffer, '\n'))
		current -> buffer = ft_handle_buffer(current, fd);
	if (!current -> buffer)
	{
		ft_remove_buffer(&buffer_list, fd);
		return (NULL);
	}
	line = ft_extract_line(current -> buffer);
	current -> buffer = ft_update_buffer(current -> buffer);
	if (!current -> buffer)
		ft_remove_buffer(&buffer_list, fd);
	return (line);
}
