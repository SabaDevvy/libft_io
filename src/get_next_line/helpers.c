/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   helpers.c                                          :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: gsabatin <marvin@42.fr>                    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/03/17 09:14:47 by gsabatin          #+#    #+#             */
/*   Updated: 2025/03/17 10:02:59 by gsabatin         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../../includes/get_next_line.h"
#include <stdlib.h>

void	ft_remove_buffer(t_buffer **head, int fd)
{
	t_buffer	*current;
	t_buffer	*previous;

	if (!head || !*head)
		return ;
	current = *head;
	previous = NULL;
	while (current && current -> fd != fd)
	{
		previous = current;
		current = current -> next;
	}
	if (!current)
		return ;
	if (previous)
		previous -> next = current -> next;
	else
		*head = current -> next;
	free(current -> buffer);
	free(current);
}
