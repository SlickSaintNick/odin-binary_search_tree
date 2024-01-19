# frozen_string_literal: true

# Node forms the structure of the BST.
class Node
  attr_accessor :data, :left, :right

  def initialize(data, left = nil, right = nil)
    @data = data
    @left = left
    @right = right
  end

  def clone
    Node.new(data, left, right)
  end
end

# Handles iterating over the tree.
class TreeIterator
  def level_order(root, &block)
    return if root.nil?

    queue = [root]
    values = []

    until queue.empty?
      current = queue.shift
      if block_given?
        yield current
      else
        values.push(current.data)
      end
      queue.push(current.left) unless current.left.nil?
      queue.push(current.right) unless current.right.nil?
    end
    return values unless block_given?
  end

  def inorder(node, values = [], &block)
    return if node.nil?

    inorder(node.left, values, &block)
    if block_given?
      yield node
    else
      values.push(node.data)
    end
    inorder(node.right, values, &block)
    values unless values.nil?
  end

  def preorder(node, values = [], &block)
    return if node.nil?

    if block_given?
      yield node
    else
      values.push(node.data)
    end
    preorder(node.left, values, &block)
    preorder(node.right, values, &block)
    values unless values.nil?
  end

  def postorder(node, values = [], &block)
    return if node.nil?

    postorder(node.left, values, &block)
    postorder(node.right, values, &block)
    if block_given?
      yield node
    else
      values.push(node.data)
    end
    values unless values.nil?
  end
end

# Tree holds a Balanced BST and associated methods.
class Tree
  attr_reader :root

  def initialize(array)
    @root = build_tree(array.sort.uniq)
    @printer = TreeIterator.new
  end

  def build_tree(array, start_index = 0, end_index = array.length - 1)
    return nil if start_index > end_index

    mid = (start_index + end_index) / 2
    root = Node.new(array[mid])
    root.left = build_tree(array, start_index, mid - 1)
    root.right = build_tree(array, mid + 1, end_index)
    root
  end

  # Method from The Odin Project.
  def pretty_print(node = @root, prefix = '', is_left = true)
    return puts 'Tree is empty.' if node.nil?

    pretty_print(node.right, "#{prefix}#{is_left ? '|   ' : '    '}", false) if node.right
    puts "#{prefix}#{is_left ? '└── ' : '┌── '}#{node.data}"
    pretty_print(node.left, "#{prefix}#{is_left ? '    ' : '|   '}", true) if node.left
  end

  def insert(value)
    return @root = build_tree([value]) if @root.nil?

    cursor = @root.clone
    cursor = value < cursor.data ? cursor.left : cursor.right until cursor.left.nil? && cursor.right.nil?
    if value < cursor.data
      @root.left = Node.new(value) if cursor.data == @root.data
      cursor.left = Node.new(value)
    else
      @root.right = Node.new(value) if cursor.data == @root.data
      cursor.right = Node.new(value)
    end
  end

  def delete(root = @root, value)
    # Base case
    return nil if root.nil?

    # Recursively look through the BST to find the node to be deleted.
    if root.data > value
      root.left = delete(root.left, value)
    elsif root.data < value
      root.right = delete(root.right, value)
    else
      # At this point, root is the node to be deleted.
      # One or no children... swap and delete.
      # Two children... replace the node with its successor and delete.
      # (Successor will have max one child by definition).
      if root.left.nil? && root.right.nil?
        @root = nil if root == @root
        root = nil
      elsif root.left.nil?
        @root = root.right if root == @root
        root = root.right
      elsif root.right.nil?
        @root = root.left if root == @root
        root = root.left
      else
        successor = find_successor(root.right)
        root.data = successor.data
        root.right = delete(root.right, successor.data)
      end
    end
    root
  end

  def find_successor(node)
    node = node.left while node.left
    node
  end

  def find(value)
    cursor = @root.clone
    cursor = value < cursor.data ? cursor.left : cursor.right until cursor.nil? || cursor.data == value
  end

  def level_order(&block)
    @printer.level_order(@root, &block)
  end

  def inorder(&block)
    @printer.inorder(@root, &block)
  end

  def preorder(&block)
    @printer.preorder(@root, &block)
  end

  def postorder(&block)
    @printer.postorder(@root, &block)
  end

  def height(root = @root)
    return nil if root.nil?

    [height(root.left), height(root.right)].compact.max.to_i + 1
  end

  def depth(node)
    cursor = @root.clone
    depth = 0

    until node.nil? || cursor.data == node.data
      cursor = node.data < cursor.data ? cursor.left : cursor.right
      depth += 1
    end

    node.nil? ? nil : depth
  end

  def balanced?(node = @root)
    return if node.nil?

    return true if (height(node.left).to_i - height(node.right).to_i).abs <= 1

    false unless balanced?(node.left) && balanced?(node.right)
  end

  def rebalance
    @root = build_tree(inorder)
  end
end

def press_enter
  puts 'Press Enter to continue...'
  gets
end

# Driver script
# Demonstrate tree creation, insertion, iteration, rebalancing.
tree = Tree.new(Array.new(15) { rand(1..100) })
tree.pretty_print
puts "Is the tree balanced? #{tree.balanced?}"
press_enter
puts 'Elements in order:'
puts tree.level_order { |value| "#{value} : "}
puts "Level Order: #{tree.level_order}"
puts "Preorder:    #{tree.preorder}"
puts "Postorder:   #{tree.postorder}"
puts "Inorder:     #{tree.inorder}"
press_enter
puts 'Adding large numbers to unbalance the tree...'
tree.insert(120)
tree.insert(140)
tree.insert(160)
tree.insert(180)
tree.insert(200)
tree.pretty_print
puts "Is the tree balanced? #{tree.balanced?}"
press_enter
tree.rebalance
tree.pretty_print
puts 'Rebalancing...'
puts "Is the tree balanced? #{tree.balanced?}"
press_enter
puts 'Elements in order:'
puts "Level Order: #{tree.level_order}"
puts "Preorder:    #{tree.preorder}"
puts "Postorder:   #{tree.postorder}"
puts "Inorder:     #{tree.inorder}"
press_enter
puts

# Demonstrate iteration over the tree using blocks
puts 'A new tree...'
tree = Tree.new(Array.new(15) { rand(1..100) })
tree.pretty_print
puts 'Even elements in tree...'
press_enter
print 'Level Order - '
tree.level_order { |node| print "#{node.data} : " if node.data.even? }
print "\n"
print 'Preorder    - '
tree.preorder { |node| print "#{node.data} : " if node.data.even? }
print "\n"
print 'Inorder     - '
tree.inorder { |node| print "#{node.data} : " if node.data.even? }
print "\n"
print 'Postorder   - '
tree.postorder { |node| print "#{node.data} : " if node.data.even? }
print "\n"
puts

# Demonstrate handling root node for insertion, deletion, rebalancing, and empty tree.
puts 'A new tree...'
tree = Tree.new([])
tree.pretty_print
press_enter
puts 'Add some values one by one...'
tree.insert(1)
tree.insert(2)
tree.insert(3)
tree.insert(4)
tree.insert(5)
puts
tree.pretty_print
puts "Is the tree balanced? #{tree.balanced?}"
press_enter
tree.rebalance
puts 'Rebalancing...'
tree.pretty_print
puts "Is the tree balanced? #{tree.balanced?}"
press_enter
puts 'Removing values...'
tree.delete(3)
tree.delete(2)
tree.delete(1)
tree.pretty_print
puts 'Removing final two values...'
tree.delete(4)
tree.delete(5)
tree.pretty_print
puts 'Finished.'
press_enter
